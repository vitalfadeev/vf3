import std.stdio;
alias log = writeln;

struct
My_socket {
    import std.socket, std.stdio, std.range, std.string, std.uni, std.conv;

    string file_name;
    Socket socket;
    char[1024] buffer;

    this (string file_name) {
        this.file_name = file_name;
        socket = new Socket (AddressFamily.UNIX, SocketType.STREAM);
        //socket.setOption (SocketOptionLevel.SOCKET, SocketOption.REUSEADDR, true);

        try {
            log ("Connecting");
            socket.connect (new UnixAddress (file_name));
        } catch (Throwable e) {
            log (e);
        }
    }

    void
    first_answer () {
        //wait "Hello!"
        //auto received = socket.receive (buffer); // wait for the server to say hello
        //log ("Server said: ", buffer[0 .. received]);
    }

    void
    write (char[] s) {
        socket.send (s);
    }

    void
    write (string s) {
        socket.send (s);
    }

    string
    read () {
        auto got = socket.receive (buffer); // wait for the server to say hello
        if (got != Socket.ERROR && got != 0) {
            string readed_string = buffer[0 .. got].idup;
            log ("a: ", readed_string);
            return readed_string;
        }
        else
        if (got == Socket.ERROR) {
            log ("socket error");
            return null;
        }
        else
        if (got == 0) {
            log ("socket disconnected");
            return null;
        }

        return null;
    }
}
