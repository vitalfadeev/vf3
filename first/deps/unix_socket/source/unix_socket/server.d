module unix_socket.server;

import core.sys.posix.unistd : read,write,close;
import core.sys.posix.sys.socket : 
    socket,AF_UNIX,SOCK_STREAM,bind,socklen_t,sa_family_t,sockaddr,
    listen,accept,recv,send,shutdown,SHUT_RDWR;
public import core.sys.posix.sys.types : mode_t;
import core.stdc.string : strcpy,strncpy;
import core.sys.posix.sys.un : sockaddr_un;
import core.sys.linux.errno : errno;
import unix_socket.errno_exception;
import file : FD,O_RDONLY,O_NONBLOCK;
import std.stdio : writeln;
alias log=writeln;


struct
Server (T_client /* =_Client */) {
    static
    ID
    open (string pathname) {
        return ID (pathname);
    }

    static
    ID
    open (string pathname, int flags) {
        return ID (pathname,flags);
    }


    struct
    ID {
        FD fd;
        alias fd this;

        string        pathname;
        T_client.ID[] clients;

        enum listen_backlog = 32;


        this (string pathname, int flags=O_RDONLY|O_NONBLOCK, mode_t mode=mode_t.init) {
            this.pathname = pathname;
            _open (flags);
        }

        this (FD fd) {
            this.fd = fd;
        }

        void
        _open (int flags) {
            _socket ();
            _bind ();
            _listen ();
        }

        void
        _socket () {
            FD _fd = .socket (AF_UNIX,SOCK_STREAM,0);

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

        T_client.ID
        accept () {
            log ("  accept:");
            auto new_fd = _accept ();
            auto new_client = T_client.open (new_fd);
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
            auto new_client = accept ();
        }

        void
        on_error () {
            log ("error: Server()");
        }
    }
}

struct
_Client {
    static
    ID
    open (FD fd) {
        return ID (fd);
    }

    struct
    ID {
        FD fd;
        alias fd this;

        string pathname;  // always empty
        bool   disconnected;

        enum _RECV_ERROR = -1;
        enum _SEND_ERROR = -1;
        enum _FILE_OPEN_ERROR = -1;
        enum _FILE_READ_ERROR = -1;
        enum _FILE_READ_EOF   =  0;

        alias E = ubyte;


        this (FD fd) {
            this.fd = fd;
        }

        Iterator!E
        read (E) (E[] buffer) {
            return Iterator!E (fd,buffer);
        }

        size_t
        write (T) (T[] buffer) {
            log ("  _Client.write:");
            log ("    fd: ",fd);
            log ("    T: ",T.stringof);
            log ("    buffer.length: ",buffer.length);
            log ("    T.sizeof: ",T.sizeof);

            size_t nbytes = .send (fd, buffer.ptr, cast (int) T.sizeof*buffer.length, 0);

            if (nbytes == _SEND_ERROR)
                throw new Errno_exception ("write: send");

            log ("send.nbytes:",nbytes);

            return nbytes;
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

        //
        struct 
        Iterator (E) {
            int fd;
            E[]  buffer;

            alias DG = int delegate (E* e);

            int 
            opApply (scope DG dg) {
                for (;;) {
                    auto nbytes = .recv (fd, buffer.ptr, cast (int) E.sizeof*buffer.length, 0);
                    //auto nbytes = .read (fd,buffer.ptr,E.sizeof*buffer.length);

                    if (nbytes == _FILE_READ_EOF) {
                        break;
                    }
                    else
                    if (nbytes == _FILE_READ_ERROR) {
                        // errno
                        throw new Errno_exception ("recv");
                    }
                    else {                        
                        if (buffer.length == 1) {
                            int result = dg (buffer.ptr);
                            if (result)
                                return result;
                        }
                        else {
                            auto e = buffer.ptr;
                            auto limit = (cast (void*) e) + nbytes;

                            for (; e < limit; e++) {
                                int result = dg (e);
                                if (result)
                                    return result;
                            }
                        }
                    }
                }

                return 0;
            }    
        }    
    }
}
