import std.stdio;
import my_socket;
alias log = writeln;

struct
Async_command_socket {
    alias T = typeof (this);
    alias DONE_DG = void delegate (string s);
    alias FAIL_DG = void delegate (string s);

    string  _service_socket_file_name;
    DONE_DG _done;
    FAIL_DG _fail;

    void
    on (DONE_DG done) {
        _done = done;
        read ();
    }

    void
    on (DONE_DG done, FAIL_DG fail) {
        _done = done;
        _fail = fail;
        read ();
    }

    void
    read () {
        log ("connecting:", "'", _service_socket_file_name, "'");
        auto socket = My_socket (_service_socket_file_name);

        string buffer = socket.read ();

        if (buffer !is null) {
            log ("a: ",buffer);
        }
    }
}
