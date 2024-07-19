module dir.dir;

import core.sys.posix.dirent : opendir,readdir_r,DIR,dirent,closedir;


struct linux_dirent {
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


struct
Dir {
    string pathname;
    enum BUF_SIZE = 1024;
    ubyte[BUF_SIZE] buf;
    linux_dirent*[] s;

    void
    load () {
        import core.sys.posix.dirent : dirent;
        import core.sys.posix.fcntl : open;
        import core.sys.posix.unistd : read,write,close;
        import core.sys.posix.fcntl : 
            O_APPEND,O_ASYNC,O_CLOEXEC,O_CREAT,
            O_DIRECT,O_DIRECTORY,O_EXCL,O_LARGEFILE,
            O_NOATIME,O_NOCTTY,O_NOFOLLOW,O_NONBLOCK,O_NDELAY,
            O_SYNC,O_TRUNC,O_RDONLY,O_WRONLY,O_RDWR;
        import syscalld : syscall, GETDENTS;
        import std.string : toStringz;

        size_t          fd, nread;
        linux_dirent*   d;
        size_t          bpos;
        char            d_type;

        fd = open (pathname.toStringz,O_RDONLY|O_DIRECTORY);

        if (fd == -1)
            throw new Exception ("open");

        // read
        for ( ; ; ) {
            nread = syscall (GETDENTS,fd,cast(size_t) buf.ptr,cast(size_t) buf.length); // Bytes

            if (nread == -1)
                throw new Exception ("getdents");

            if (nread == 0)
                break;

            for (bpos=0; bpos<nread; ) {
                d = cast (linux_dirent*) (buf.ptr + bpos);
                s ~= d;

                bpos += d.d_reclen;
            }
        }
    }

    void
    sort () {
        // by name
        import std.algorithm : sort;
        import core.stdc.string : strcmp;

        s.sort!((a,b)=>strcmp (a.d_name.ptr,b.d_name.ptr)<0) ();
    }


    alias DG = int delegate (linux_dirent* e);

    int 
    opApply (scope DG dg) {
        foreach (ref e; s) {
            int result = dg (e);

            if (result)
                return result;
        }

        return 0;
    }    
}


//struct
//Dirent {
//    import core.sys.posix.dirent : dirent;

//    dirent _super;
//    alias _super this;
//}

unittest {
    import std.stdio : printf, writeln, writefln, writef;
    import std.string : fromStringz;

    auto ds = Dir2 ("/");
    ds.load ();
    ds.sort ();

    foreach (linux_dirent* d; ds) {
        writef ("%8x ", d.d_ino);
        writef ("%-7s ", d.d_type);

        writef ("%s", d.d_name.fromStringz);
        writeln ();        
    }
}
