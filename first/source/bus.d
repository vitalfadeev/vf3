import std.string;
import log : log;
import core.time;
import qa_protocol;
//import query_registry;
import db;
//import server_socket_base;
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
