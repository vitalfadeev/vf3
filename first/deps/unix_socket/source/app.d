import std.stdio : writeln;
import unix_socket.input_range;
alias log=writeln;

void main()
{
    import unix_socket.file : O_RDONLY,O_NONBLOCK;
	string input_dev = 
		"/dev/input/by-id/usb-LITEON_Technology_USB_Keyboard-event-kbd";
	auto f = Custom_file (input_dev);
	f.open (O_RDONLY|O_NONBLOCK);
	log ("f.fd: ",f.fd);

	//
	import std.path, std.file;
	string socket_path = "/tmp/vf.soc";
	if (socket_path.exists)
		socket_path.remove ();
	auto server = Custom_server (socket_path);
	server.open (O_RDONLY|O_NONBLOCK);
	log ("server.fd: ",server.fd);

	//
	//auto _select = Custom_select ();
	//_select.dev_input_event = f;
	//_select.server = server;
	//while (true)
	//	_select.go ();

	import unix_socket.select;
	while (true) {
		Select (f,server,server.clients);

		// remove disconected clients
		server.remove_disconected_clients ();
	}

	//
version (__poll__) {
	import poll : Poll;
	auto _poll = Poll ();
	_poll.files ~= f;
	_poll.files ~= cast (File) server;
	_poll.dg  ~= 
		(file) { 
			log (file);
			Input_event evt;
			file.read (evt);
			log ("event: ",evt);
		};
	_poll.go ();
}
}


struct 
Input_event {
    timeval time;
    ushort  type;
    ushort  code;
    uint    value;

    import core.sys.posix.sys.time : timeval;
};


struct
Custom_file {
	import unix_socket.file : File,FD;

	File _super;
	alias _super this;

	this (FD fd) {
	    this._super.fd = fd;
	}

	this (string pathname) {
	    this._super.pathname = pathname;
	}

    void
    on_select () {
    	log ("  on_select");
        Input_event[1] input_event;
        auto buf = _super.read (input_event[]);
        log ("  buf.legth:",buf.length);
        //on_data ();
    }    
}

struct
Custom_server {
	import unix_socket.server : Server;
	import unix_socket.file : FD;

	Server!_Client _super;
	alias _super this;

	this (FD fd) {
	    this._super.fd = fd;
	}

	this (string pathname) {
	    this._super.pathname = pathname;
	}

    //void
    //on_select () {
	//    log ("  on_select");
	//    //on_data ();
	//    auto new_client = _super.accept ();
    //}    

	struct
	_Client {
		import unix_socket.server : _Client;

		_Client _super;
		alias _super this;

		void
	    on_select () {
	    	log ("on_select");
			log ("  client");
			char[1024] buffer;
			auto buf = _super.read (buffer);
			log ("  buf.legth:",buf.length);
			log ("  buf:",buf);
			if (buf.length == 0) {
				log ("  client disconnected");
				_super.close ();
				_super.on_disconnected ();  // remove from server.clients
			    //on_client_disconnected (client);
			}
			else {
				on_data (buf.idup);
			}
	    }

	    void
	    on_data (string s) {
	        log ("  on_data: ",s);
	    }
	}
}
