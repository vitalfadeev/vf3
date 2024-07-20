module file;

version (linux) version (X86_64) version = linux_X86_64;
version (linux) pragma (msg,"linux");
version (X86_64) pragma (msg,"X86_64");
version (Linux_X86_64) pragma (msg,"Linux_X86_64");


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

public import core.sys.posix.sys.types : mode_t;
import core.sys.posix.fcntl : open;
import core.sys.posix.unistd : close;
import core.sys.posix.unistd : read,write,close;
import syscalld : syscall,GETDENTS,GETDENTS64;
import errno_exception;
import file;
alias log=writeln;

alias FD = int;


struct
File {
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

    static
    ID
    open (string pathname, int flags, mode_t mode) {
        return ID (pathname,flags,mode);
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
            log ("flags: ", flags, ": ", flags & O_NONBLOCK ? "O_NONBLOCK" : "");

            fd = .open (pathname.toStringz,flags,mode);

            if (fd == _FILE_OPEN_ERROR)
                throw new Errno_exception ("open");
        }

        this (FD fd) {
            this.fd = fd;
        }

        Iterator!E
        read (E) (E[] buffer) {
            return Iterator!E (fd,buffer);
        }

        void
        write () {
            //
        }
        
        void
        seek () {
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
                        import core.sys.linux.errno : errno;
                        import core.stdc.errno : EAGAIN;
                        if (errno == EAGAIN) {  // Non-blocking I/O has been selected using O_NONBLOCK and no data was immediately available for reading. 
                            break;
                        } 
                        else {                            
                            throw new Errno_exception ("read");
                        }
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

    alias E = ubyte;
    alias EIterator = ID.Iterator!E;
    alias UByteIterator = ID.Iterator!ubyte;

    enum _FILE_OPEN_ERROR = -1;
    enum _FILE_READ_ERROR = -1;
    enum _FILE_READ_EOF   =  0;
}

unittest {
    import std.stdio : write,writef;

    auto f = File.open ("test/1.txt");
    File.E[] buffer;
    buffer.length = 10;
    log ("File.read");
    auto iterator = f.read (buffer);
    foreach (e; iterator)
        write (cast (char) *e);
    writeln ();
    f.close ();    
}


struct
Dir {
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

    static
    ID
    open (string pathname, int flags, mode_t mode) {
        return ID (pathname,flags,mode);
    }

    struct
    ID {
        FD fd;
        alias fd this;

        this (string pathname, int flags=O_RDONLY|O_DIRECTORY, mode_t mode=mode_t.init) {
            fd = .open (pathname.toStringz,flags,mode);

            if (fd == _DIR_OPEN_ERROR)
                throw new Errno_exception ("open");
        }

        Iterator!E
        read (E[] buffer) {
            return Iterator!E (fd, buffer);
        }

        struct 
        Iterator (E) {
            FD fd;
            E[]  buffer;

            alias DG = int delegate (E* e);

            int 
            opApply (scope DG dg) {
                void*  e;
                void*  limit;
                size_t nbytes;

                for ( ; ; ) {
                    nbytes = .syscall (GETDENTS64,fd,cast(size_t) buffer.ptr,cast(size_t) E.sizeof*buffer.length); // Bytes

                    if (nbytes == _DIR_READ_EOF) {
                        break;
                    }
                    else
                    if (nbytes == _DIR_READ_ERROR)
                        throw new Errno_exception ("syscall GETDENTS");

                    //
                    e = buffer.ptr;
                    limit = (cast (void*) e) + nbytes;

                    for (; e < limit; e += (cast (E*) e).d_reclen) {
                        int result = dg (cast (E*) e);

                        if (result)
                            return result;
                    }
                }

                return 0;
            }    
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
    }

    alias E = linux_dirent64;

version (linux_X86_64) {  // Posix
    pragma (msg,"linux_X86_64");
    struct 
    linux_dirent64 {
        alias ino64_t = ulong;
        alias off64_t = ulong;

        ino64_t   d_ino;    // 64-bit inode number
        off64_t   d_off;    // Not an offset; see getdents()
        ushort    d_reclen; // Size of this dirent
        ubyte     d_type;   // File type
        char[255] d_name;   // Filename (null-terminated)

        Type
        d_type_ () {
            return cast (Type) d_type;
        }

        enum Type : ubyte {
            DT_UNKNOWN = 0,
            DT_FIFO = 1,
            DT_CHR = 2,
            DT_DIR = 4,
            DT_BLK = 6,
            DT_REG = 8,
            DT_LNK = 10,
            DT_SOCK = 12,
            DT_WHT = 14
        };
    };
}
else {
    struct 
    linux_dirent {
        import core.sys.posix.sys.types : off_t;

        long      d_ino;
        off_t     d_off;
        ushort    d_reclen;
        char[255] d_name;

        Type
        d_type () {
            return cast (Type) *((cast (ubyte*) &this) + d_reclen - 1);
        }

        enum Type : ubyte {
            DT_UNKNOWN = 0,
            DT_FIFO = 1,
            DT_CHR = 2,
            DT_DIR = 4,
            DT_BLK = 6,
            DT_REG = 8,
            DT_LNK = 10,
            DT_SOCK = 12,
            DT_WHT = 14
        };
    };
}

    enum _DIR_OPEN_ERROR = -1;
    enum _DIR_READ_ERROR = -1;
    enum _DIR_READ_EOF   =  0;
}


version (linux_X86_64)
unittest {
    import std.stdio : writef;
    import std.string : fromStringz;

    auto d = Dir.open ("/");
    Dir.E[] buffer;
    buffer.length = 1000;

    log ("Dir.read");

    auto iterator = d.read (buffer); // Iterator

    foreach (_dirent; iterator) {
        writef ("%8X ", _dirent.d_ino);
        writef ("%-7s ", _dirent.d_type);

        writef ("%s", _dirent.d_name.fromStringz);
        writeln ();   
    }     
}

