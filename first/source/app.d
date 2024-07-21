import std.stdio;
import s;
import bus;
import globals;
alias log=writeln;

void main()
{
	Globals.load ();

	//
	import file : O_RDONLY,O_NONBLOCK;
	string input_dev = 
		"/dev/input/by-id/usb-LITEON_Technology_USB_Keyboard-event-kbd";
	auto keyboard_input = Custom_file.open (input_dev,O_RDONLY|O_NONBLOCK);  // File.ID
	log ("keyboard_input.fd: ",keyboard_input.fd);

	//
	import std.path, std.file;
	string socket_path = "/tmp/vf.soc";
	if (socket_path.exists)
		socket_path.remove ();
	auto socket_server = Custom_server.open (socket_path, O_RDONLY|O_NONBLOCK);  // Server.ID
	log ("server.fd: ",socket_server.fd);

	import unix_socket.select;
	while (true) {
		Select (
			keyboard_input,
			socket_server,
			socket_server.clients
		);

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
	    	ubyte[] buffer;
	    	buffer.length = Input_event.sizeof;  // for 1 Input_event
	        foreach (e; this.read (buffer).by_type!Input_event)
	            log ("    ", e);
	    }
	}
}

auto
by_type (T,R) (R buffers) {
	struct 
	_by_type {
	    R buffers;

	    alias DG = int delegate (T e);

	    int 
	    opApply (scope DG dg) {
	    	int result;
	    	T e;
	    	size_t i;

	    	foreach (buffer; buffers) {
		    	foreach (c; buffer) {
		    		(cast (ubyte*) (&e))[i] = c;

		    		i++;

		    		if (i == T.sizeof) {
		    			result = dg (e);
		    			if (result)
		    				return result;

		    			i = 0;
		    		}
	    		}
	    	}

	    	// last line without '\n'
	    	if (i != 0) {
	    		// incomplete e
	    	}


	        return 0;
	    }
	}

	return _by_type (buffers);
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
					if (*e == '\n') { // iterate each line \n
						on_data (s);
						s.length = 0;
						length = 0;
					}
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
