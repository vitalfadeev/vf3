import std.string : toStringz;
// #include <linux/fcntl.h>
// #include <linux/types.h>
// #include <sys/types.h>
// #include <sys/stat.h>
// #include <fcntl.h>        
import core.sys.posix.fcntl : fcntl,F_GETFL;
public import core.sys.posix.fcntl : 
    O_APPEND,O_ASYNC,O_CLOEXEC,O_CREAT,
    O_DIRECT,O_DIRECTORY,O_EXCL,O_LARGEFILE,
    O_NOATIME,O_NOCTTY,O_NOFOLLOW,O_NONBLOCK,O_NDELAY,
    O_SYNC,O_TRUNC,O_RDONLY,O_WRONLY,O_RDWR;

public import core.sys.posix.sys.stat : 
    S_IRWXU,S_IRUSR,S_IWUSR,S_IXUSR,S_IRWXG,
    S_IRGRP,S_IWGRP,S_IXGRP,S_IRWXO,S_IROTH,S_IWOTH,S_IXOTH;

public import core.sys.posix.sys.types : mode_t;
import core.sys.posix.fcntl : open;
import core.sys.posix.unistd : close;
import core.sys.posix.unistd : read,write,close;
import std.stdio;
import errno_exception;
alias log = writeln;

alias FD = int;


struct
Socket_File {
    static
    ID
    open (string pathname) {
        return ID (pathname);
    }

    static
    ID
    open (FD fd) {
        return ID (fd);
    }

    struct
    ID {
        FD fd;
        alias fd this;

        this (string pathname, int flags=O_RDONLY, mode_t mode=mode_t.init) {
            _open (pathname,flags,mode);
            _connect (pathname);
        }

        this (FD fd) {
            this.fd = fd;
        }

        void
        _open (string pathname, int flags, mode_t mode) {
            import core.sys.posix.sys.socket : 
                socket,AF_UNIX,SOCK_STREAM,socklen_t,sa_family_t,sockaddr,
                recv,send,shutdown,SHUT_RDWR;

            fd = socket (AF_UNIX,SOCK_STREAM,0);

            if (fd == _SOCKET_OPEN_ERROR)
                throw new Errno_exception ("open");
        }

        void
        _connect (string pathname) {
            import core.sys.posix.sys.socket : 
                socket,AF_UNIX,SOCK_STREAM,socklen_t,sa_family_t,sockaddr,
                recv,send,shutdown,SHUT_RDWR;
            import core.sys.posix.sys.socket : connect;
            import core.sys.posix.sys.un : sockaddr_un;
            import core.stdc.string : strcpy,strncpy;

            sockaddr_un addr;
            socklen_t   addrlen;
            addr.sun_family = AF_UNIX;
            strncpy (cast (char*) addr.sun_path.ptr, pathname.ptr, pathname.length);
            addr.sun_path[pathname.length] = 0;
            addrlen = addr.sizeof;

            auto err = connect (fd,cast (sockaddr*) &addr,addrlen);

            if (err == _SOCKET_CONNECT_ERROR)
                throw new Errno_exception ("connect");
        }        

        Iterator!E
        read (E) (E[] buffer) {
            return Iterator!E (fd,buffer);
        }

        void
        write (string line) {
            auto n = .write (fd,line.ptr,line.length);
        }
        
        void
        seek () {
            //
        }

        void
        flush () {
            //
        }

        void
        close () {
            .close (fd);
        }

        //
        void
        on_select () {
            //
        }
        
        void
        on_error () {
            import core.sys.linux.errno : errno;
            log ("error: ",format_error (errno));
        }


        //
        void
        _send (string s) {
            import core.sys.posix.sys.socket : send;
            send (fd, s.ptr, s.length, 0);
        }


        //
        struct 
        Iterator (E) {
            FD  fd;
            E[] buffer;

            alias DG = int delegate (E* e);

            int 
            opApply (scope DG dg) {
                for (;;) {  // for read more than buffer size
                    auto nbytes = .read (fd,buffer.ptr,E.sizeof*buffer.length);

                    if (nbytes == _FILE_READ_EOF) {
                        break;
                    }
                    else
                    if (nbytes == _FILE_READ_ERROR) {
                        if ((fcntl (fd, F_GETFL)) & O_NONBLOCK) {
                            import core.sys.linux.errno : errno;
                            import core.stdc.errno : EAGAIN;
                            if (errno == EAGAIN) {  // Non-blocking I/O has been selected using O_NONBLOCK and no data was immediately available for reading. 
                                break;
                            }                             
                            else
                                throw new Errno_exception ("read");
                        }
                        else
                            throw new Errno_exception ("read");
                    }
                    else {  // OK
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

    enum _FILE_OPEN_ERROR = -1;
    enum _FILE_READ_ERROR = -1;
    enum _FILE_READ_EOF   =  0;
    enum _SOCKET_CONNECT_ERROR = -1;
    enum _SOCKET_OPEN_ERROR    = -1;
}
