import std.stdio : writeln;
import unix_socket.input_range;
alias log=writeln;

void main()
{
    import file : O_RDONLY,O_NONBLOCK;
	string input_dev = 
		"/dev/input/by-id/usb-LITEON_Technology_USB_Keyboard-event-kbd";
    auto f = Custom_file.open (input_dev,O_RDONLY|O_NONBLOCK);  // File.ID
	log ("f.fd: ",f.fd);

	//
	import std.path, std.file;
	string socket_path = "/tmp/vf.soc";
	if (socket_path.exists)
		socket_path.remove ();
	auto server = Custom_server.open (socket_path, O_RDONLY|O_NONBLOCK);  // Server.ID
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
	import file : File,FD,O_RDONLY,O_NONBLOCK;

	File _super;
	alias _super this;

	static
	ID
	open (string pathname) {
	    return ID (File.ID (pathname));
	}

	static
	ID
	open (string pathname, int flags) {
	    return ID (File.ID (pathname,flags));
	}

	static
	ID
	open (FD fd) {
	    return ID (File.ID (fd));
	}

	struct
	ID {
		File.ID _super;
		alias _super this;

		void
		on_select () {
			log ("  on_select");
			log ("    fd: ",fd);
		    Input_event[] buffer;
		    buffer.length = 1;
		    auto iterator = this.read (buffer);
		    foreach (e; iterator)
		        writeln (e);
		}    
	}
}

struct
Custom_server {
	import unix_socket.server : Server;
	import file : FD;

	Server!_Client _super;
	alias _super this;


	struct
	_Client {
		import unix_socket.server : _Client;

		_Client _super;
		alias _super this;

		static
		ID
		open (FD fd) {
		    return ID (_Client.ID (fd));
		}

		struct
		ID {
			_Client.ID _super;
			alias _super this;

			void
		    on_select () {
		    	log ("on_select");
				log ("  client");
				char[] buffer;
				buffer.length = 1000;
				auto iterator = this.read (buffer);
				size_t length;
				string s;
				foreach (e; iterator) {
 					s ~= *e;
					length++;
				}
				if (length == 0) {
					log ("  client disconnected");
					_super.close ();
					_super.on_disconnected ();  // remove from server.clients
				    //on_client_disconnected (client);
				}
				else {
					on_data (s);
				}
		    }

		    void
		    on_data (string s) {
		        log ("  on_data: ",s);
		    }
	    }
	}
}
