import std.string;
import log : log;
import core.time;
import qa_protocol;
import query_registry;
import db;
import server_socket_base;
import mime_database;


struct
Bus {
    Event[] s;
}

struct
Event {
    string name;  // like a "*.mp4"
}

struct
Regex_callback {
    string regex;
    void function () callback;
}

class 
My_server : Server_socket_base {
    Query_registry query_registry;
    Db             db;
    Mime_database  mime_db;

    this (string socket_path) {
        super (socket_path);
        db.load ();
        mime_db.load ();
    }

    bool
    verify_client (Socket client) {
        return false;
    }

    //
    override
    void
    on_data (Socket client, string s) {
        auto query_id = query_registry.add (s,client);
        //query_registry.save_s (client,s);

        auto a = QA_protocol ().q (s);

        log ("a: ", a);
        client.send (a);

        //import std.process : executeShell;
        //string cmd = "echo -e \"1\\n\" | bin/menu";
        //auto ls = executeShell (cmd);
        //if (ls.status != 0)
        //    log ("Failed to retrieve file listing");
        //else
        //    log (ls.output);

        //system ("xterm -e  \"echo -e \"1\\\\n2\\\\n3\" | percol\"");
        //client.shutdown (SocketShutdown.SEND);
    }

    override
    void
    on_client_connected (Socket client) {
        //auto query_id = query_registry.add ("",client);
    }

    override
    void
    on_client_disconnected (Socket client) {
        query_registry.remove (client);        
    }
}

// ocat /tmp/vf_bus.soc STDOUT
//
// C: girls.mp4 ?
// S: girls.mp4 mpv.open !
// C: girls.mp4 mpv.open ?
// S: girls.mp4 mpv.open ! // system ("mpv girls.mp4")
//
// *.mp4
//   // open
//   mpv $URL
//
// *
//   // copy
//   cp $URL ...
//
// C: girls.mp4
// S: girls.mp4 [mpv.open,file.copy]
// C: girls.mp4 mpv.open
// S: girls.mp4 mpv.open // system ("mpv girls.mp4")
//
