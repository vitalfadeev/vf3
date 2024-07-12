import std.socket;
import std.stdio;
alias log = writeln;

class
Client_socket_base : Socket {
    string socket_path;
    char[1024] buffer;

    this (string socket_path) {
        this.socket_path = socket_path;
        super (AddressFamily.UNIX, SocketType.STREAM);
        //super.setOption (SocketOptionLevel.SOCKET, SocketOption.REUSEADDR, true);
    }

    void
    go (string[] input) {
        try {
            log ("Connecting");
            this.connect (new UnixAddress (socket_path));
            on_connected ();
        } catch (Throwable e) {
            log (e);
        }

        foreach (line; input) {
            log ("q: ", line);
            this.write (line);

            string buffer = this.read ();

            if (buffer !is null)
                on_data (buffer);
        }
    }

    void
    go () {
        try {
            log ("Connecting");
            this.connect (new UnixAddress (socket_path));
            on_connected ();
        } catch (Throwable e) {
            log (e);
        }
    }

    //
    void
    first_answer () {
        //wait "Hello!"
        //auto received = this.receive (buffer); // wait for the server to say hello
        //log ("Server said: ", buffer[0 .. received]);
    }

    void
    write (char[] s) {
        this.send (s);
    }

    void
    write (string s) {
        this.send (s);
    }

    string
    read () {
        auto got = this.receive (buffer); // wait for the server to say hello

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

    //
    void
    on_connected () {
        //
    }

    void
    on_disconnected (Socket server) {
        //
    }

    void
    on_data (string data) {
        //
    }
}


class 
Inpur_reader (T) {
    string input_dev;

    this (string input_dev) {
        this.input_dev = input_dev;
    }

    void
    go () {
        import std.file;
        import std.stdio;

        //pollfd[1] fds;

        //fds[0].fd = open (input_dev, O_RDONLY|O_NONBLOCK);
        auto f = File (input_dev);
        T buffer;

        while (true) {
            f.rawRead ((&buffer)[0..1]);
            log (buffer.type);
        }
    }
}


class
Raw_client_socket_base (T) : Socket {
    string socket_path;
    T buffer;

    this (string socket_path) {
        this.socket_path = socket_path;
        super (AddressFamily.UNIX, SocketType.STREAM);
        //super.setOption (SocketOptionLevel.SOCKET, SocketOption.REUSEADDR, true);
    }

    void
    go () {
        try {
            log ("Connecting");
            import std.string : toStringz;
            import core.stdc.string : strlen;
            auto cstr = socket_path.toStringz;
            auto clen = strlen (cstr);
            //int connect(int, const scope sockaddr*, socklen_t);
            auto saddr = new UnixAddress (socket_path).name;
            import core.sys.posix.sys.socket : connect;
            int ret = connect (cast (int) this.handle,saddr,100);
            log ("connect.ret:",ret);

            this.connect (new UnixAddress (socket_path));
            on_connected ();
        } catch (Throwable e) {
            log (e);
        }

        while (true) {
            auto buffer = this.read ();
            if (buffer !is null)
                on_data (buffer);
            else
                break;
        }
    }

    T*
    read () {
        auto got = this.receive ((&buffer)[0..1]); // wait for the server to say hello

        if (got != Socket.ERROR && got != 0) {
            log (".");
            return &buffer;
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

    //
    void
    on_connected () {
        //
    }

    void
    on_disconnected (Socket server) {
        //
    }

    void
    on_data (T* data) {
        //
    }
}
