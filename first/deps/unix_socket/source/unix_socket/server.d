module unix_socket.server;

import core.sys.posix.unistd : read,write,close;
import core.sys.posix.sys.socket : 
    socket,AF_UNIX,SOCK_STREAM,bind,socklen_t,sa_family_t,sockaddr,
    listen,accept,recv,send,shutdown,SHUT_RDWR;
import core.stdc.string : strcpy,strncpy;
import core.sys.posix.sys.un : sockaddr_un;
import core.sys.linux.errno : errno;
import unix_socket.errno_exception;
import unix_socket.file : FD;
import std.stdio : writeln;
alias log=writeln;


struct
Server (T_client /* =_Client */) {
    //File _super;
    //alias _super this;
    FD        fd;
    string    pathname;
    T_client[] clients;

    enum listen_backlog = 32;


    this (FD fd) {
        this.fd = fd;
    }

    this (string pathname) {
        this.pathname = pathname;
    }

    void
    open (int flags) {
        _socket ();
        _bind ();
        _listen ();
    }

    void
    _socket () {
        FD _fd = socket (AF_UNIX,SOCK_STREAM,0);

        if (_fd == -1) {
            log ("error: ",format_error (errno));
            on_error ();
            throw new Errno_exception ("Server");
        }
        else
            this.fd = _fd;
    }

    void
    _bind () {
        sockaddr_un addr;
        socklen_t   addrlen;
        addr.sun_family = AF_UNIX;
        strncpy (cast (char*) addr.sun_path.ptr, pathname.ptr, pathname.length);
        addr.sun_path[pathname.length] = 0;
        addrlen = addr.sizeof;

        auto err = .bind (fd, cast (sockaddr*) &addr, addrlen);

        if (err == 0) {
            // ok
        }
        else {
            // errno
            throw new Errno_exception ("bind");
        }
    }

    void
    _listen () {
        auto err = .listen (fd,listen_backlog);

        if (err == 0) {
            // ok
            log ("listening");
        }
        else {
            // errno
            throw new Errno_exception ("listen");
        }
    }

    T_client
    accept () {
        log ("  accept:");
        auto new_fd = _accept ();
        auto new_client = T_client (_Client (new_fd));
        clients ~= new_client;
        log ("    new_fd:",new_fd);
        return new_client;
    }

    FD
    _accept () {
        sockaddr_un caddr;
        socklen_t clen = caddr.sizeof;

        FD new_client = .accept (fd,cast (sockaddr *) &caddr,&clen);
        
        if (new_client < 0) {
             log ("error: on accept");
             throw new Errno_exception ("accept");
         }

         return new_client;
    }

    void
    remove_disconected_clients () {
        import std.algorithm : remove;
        size_t[] idxs_for_remove;
        foreach (i,ref client; clients)
            if (client.disconnected)
                idxs_for_remove ~= i;
        foreach_reverse (i; idxs_for_remove)
            clients = clients.remove (i);
        log ("  remove_disconected_clients: ", idxs_for_remove.length);
    }

    void
    on_select () {
        log ("  Server.on_select");
        //on_data ();
        auto new_client = accept ();
    }

    void
    on_error () {
        log ("error: Server()");
    }
}

struct
_Client {
    FD     fd;
    string pathname;  // always empty
    bool   disconnected;

    enum _RECV_ERROR = -1;
    enum _SEND_ERROR = -1;

    T[]
    read (T) (T[] buffer) {
        log ("  _Client.read:");
        log ("    fd: ",fd);
        log ("    T: ",T.stringof);
        log ("    buffer.length: ",buffer.length);
        log ("    T.sizeof: ",T.sizeof);

        size_t nbytes = .recv (fd, buffer.ptr, cast (int) T.sizeof*buffer.length, 0);

        if (nbytes == _RECV_ERROR) {
            // error
            throw new Errno_exception ("read: recv");
        }

        log ("recv.nbytes:",nbytes);

        return buffer[0..nbytes/T.sizeof];
    }

    T[]
    write (T) (T[] buffer) {
        log ("  _Client.write:");
        log ("    fd: ",fd);
        log ("    T: ",T.stringof);
        log ("    buffer.length: ",buffer.length);
        log ("    T.sizeof: ",T.sizeof);

        size_t nbytes = .send (fd, buffer.ptr, cast (int) T.sizeof*buffer.length, 0);

        if (nbytes == _SEND_ERROR) {
            // error
            throw new Errno_exception ("write: send");
        }

        log ("send.nbytes:",nbytes);

        return buffer[0..nbytes/T.sizeof];
    }


    void
    close () {
        .shutdown (fd,SHUT_RDWR);
        .close (fd);
    }

    void
    on_select () {
        //
    }

    void
    on_disconnected () {
        disconnected = true;
    }
}
