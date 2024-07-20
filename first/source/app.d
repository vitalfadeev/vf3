import std.stdio;
import s;
import bus;
import globals;
alias log=writeln;

void main()
{
	Globals.load ();

	//
    import unix_socket.file : O_RDONLY,O_NONBLOCK;
	string input_dev = 
		"/dev/input/by-id/usb-LITEON_Technology_USB_Keyboard-event-kbd";
	auto keyboard_input = Custom_file (input_dev);
	keyboard_input.open (O_RDONLY|O_NONBLOCK);
	log ("keyboard_input.fd: ",keyboard_input.fd);

	//
	import std.path, std.file;
	string socket_path = "/tmp/vf.soc";
	if (socket_path.exists)
		socket_path.remove ();
	auto socket_server = Custom_server (socket_path);
	socket_server.open (O_RDONLY|O_NONBLOCK);
	log ("server.fd: ",socket_server.fd);

	import unix_socket.select;
	while (true) {
		Select (keyboard_input,socket_server,socket_server.clients);

		// remove disconected clients
		socket_server.remove_disconected_clients ();
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
			//alias StringIterator = _super.Iterator;
			//auto iterator = _super.read!StringIterator (buffer);
			auto iterator = _super.read (buffer);
			// char s to string
			size_t length;
			string line;
			foreach (e; iterator) {
				line ~= *e;
				if (*e == '\n') {
					on_data (line);
					line.length = 0;
				}
				length++;
			}
			if (length == 0) {
				log ("  client disconnected");
				_super.close ();
				_super.on_disconnected ();  // remove from server.clients
			    //on_client_disconnected (client);
			}
	    }

	    void
	    on_data (string s) {
	        log ("  on_data: ",s);

	        //auto query_id = query_registry.add (s,client);
	        //query_registry.save_s (client,s);

	        import std.string : strip;
	        import qa_protocol;
	        auto a = QA_protocol ().q (s.strip);

	        log ("a: ", a);
	        _super.write (a);	        
	    }
	}
}


// hotkeys/
//   ctrl-c -> copy_to_clipboard
//   ctrl-alt-t -> terminal

// Event // from menu 
//  id_of_query
//  done
//  selected_item

// 1.mp4
// query_id = new_query_id // for client "1" for query "1.mp4"
// query_registry
//   query_id,client_socket,question
// menu (query_id,items)

// menu
//   done
//     send_event (menu,done,quesy_id,selected_item)

// socket -> 1.mp4
// events -> Event (menu,done,qid,item)

// socket <- 1.mp4
// socket <- event:menu,done,qid,item

// echo "event:menu,done,quesy_id,selected_item" | socat /tmp/vf.soc
// VF_QUERY_ID
// VF_QUERY_STRING

// S:
// C: 1.mp4
// S: 2
// copy_to
// mpv_open
// ...(menu on client side)...
// C: mpv_open 1.mp4
// S: 1
//   echo 1.mp4
//   mpv 1.mp4
// ...(execute on client side)...
