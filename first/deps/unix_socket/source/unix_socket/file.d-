module unix_socket.file;

import std.stdio : writeln;
import std.string : toStringz;
// #include <linux/fcntl.h>
// #include <linux/types.h>
// #include <sys/types.h>
// #include <sys/stat.h>
// #include <fcntl.h>        
public import core.sys.posix.fcntl : 
    O_APPEND,O_ASYNC,O_CLOEXEC,O_CREAT,
    O_DIRECT,O_DIRECTORY,O_EXCL,O_LARGEFILE,
    O_NOATIME,O_NOCTTY,O_NOFOLLOW,O_NONBLOCK,O_NDELAY,
    O_SYNC,O_TRUNC,O_RDONLY,O_WRONLY,O_RDWR;

public import core.sys.posix.sys.stat : 
    S_IRWXU,S_IRUSR,S_IWUSR,S_IXUSR,S_IRWXG,
    S_IRGRP,S_IWGRP,S_IXGRP,S_IRWXO,S_IROTH,S_IWOTH,S_IXOTH;

import core.sys.posix.sys.types : mode_t;
import core.sys.posix.fcntl : open;
import core.sys.posix.unistd : close;
import core.sys.posix.unistd : read,write,close;
import unix_socket.errno_exception;
alias log=writeln;
alias FD = int;


struct
File {
    FD     fd;
    string pathname;

    enum _FILE_READ_ERROR = -1;
    enum _FILE_READ_EOF   = 0;

    this (FD fd) {
        this.fd = fd;
    }

    this (string pathname) {
        this.pathname = pathname;
    }

    //int open(const char *pathname, int flags);
    //int open(const char *pathname, int flags, mode_t mode);        
    void
    open (int flags) {
        auto _fd = .open (pathname.toStringz,flags);

        if (_fd == -1) {
            on_error ();
            throw new Errno_exception ("File.open");
        }
        else
            fd = _fd;
    }

    void
    open (int flags, mode_t mode) {
        auto _fd = .open (pathname.toStringz,flags,mode);

        if (_fd == -1) {
            on_error ();
            throw new Errno_exception ("File.open");
        }
        else
            fd = _fd;
    }

    void 
    close () {
        .close (fd);
    }

    T[]
    read (T) (T[] buffer) {
        log ("  File.read:");
        log ("    fd: ",fd);
        log ("    T: ",T.stringof);
        log ("    buffer.length: ",buffer.length);
        log ("    T.sizeof: ",T.sizeof);
        auto nbytes = .read (fd,buffer.ptr,T.sizeof*buffer.length);

        if (nbytes == _FILE_READ_EOF) {
            // EOF
            log ("EOF");
            return [];
        }
        else
        if (nbytes == _FILE_READ_ERROR) {
            // error
            log ("error");
            // errno
            throw new Errno_exception ("File.read");
            return [];
        }

        return buffer[0..nbytes/T.sizeof];
    }

    void
    on_select () {
        //
    }
    
    void
    on_error () {
        import core.sys.linux.errno : errno;
        log ("error: ",format_error (errno));
    }
}
