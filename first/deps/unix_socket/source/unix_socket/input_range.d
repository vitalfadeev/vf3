module unix_socket.input_range;

import std.file;
import std.stdio;

struct 
Input_range {
    string         file_path;
    File           file;
    Input_event[1] buffer;

    alias E  = Input_event;
    alias DG = int delegate (ref E e);


    this (string file_path) {
        this.file_path = file_path;
    }

    void 
    open () {
        import core.sys.linux.fcntl : open;
        import core.sys.linux.fcntl : O_RDONLY;
        import core.sys.linux.fcntl : fcntl;
        import core.sys.linux.fcntl : O_NONBLOCK;
        import core.sys.linux.fcntl : F_SETFL;
        import core.sys.linux.fcntl : F_GETFL;
        import core.sys.linux.errno : errno;

        file = File (file_path,"rb");
        auto f = file.fileno;

        // set the file description to non blocking
        //int flags = fcntl (f,F_GETFL,0);
        //fcntl (f,F_SETFL,flags | O_NONBLOCK);
    }

    void
    close () {
        file.close ();
    }

    auto
    read () {
        return file.rawRead (buffer);
    }

    int 
    opApply (scope DG dg) {
        open ();

        foreach (ref e; read ()) {
            int result = dg (e);

            if (result) {
                close ();
                return result;
            }
        }

        close ();
        return 0;
    }    
}

struct 
Input_event {
    Timeval time;
    ushort  type;
    ushort  code;
    uint    value;

    alias Timeval = ulong;
};

