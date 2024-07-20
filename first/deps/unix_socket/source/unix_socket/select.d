module unix_socket.select;

import std.stdio : writeln;
import unix_socket.errno_exception;
import file : FD;
alias log=writeln;

auto
Select (SOURCES...) (ref SOURCES srcs)  {
    import core.sys.posix.sys.time : timeval;
    import core.sys.posix.sys.select : 
        select,FD_CLR,FD_ISSET,FD_SET,FD_ZERO,fd_set;
    enum int _SELECT_ERROR   = -1;
    enum int _SELECT_TIMEOUT = 0;

    fd_set  r_fds;
    int     nfds;  // max.fd + 1;
    timeval timeout;

    // maxfd
    int maxfd = 0;
    static foreach (src; srcs) {
        static if (trait_has_fd!(typeof(src))) {
            if (src.fd > maxfd)
                maxfd = src.fd;
        }
        else
        static if (trait_iterable_has_fd!(typeof(src))) {
            foreach (ref e; src)
                if (e.fd > maxfd)
                    maxfd = e.fd;
        }
        else
            static assert (0, "expect field \"fd\" for type \"" ~ __traits (fullyQualifiedName,typeof(src)) ~ "\" in " ~ __traits (identifier,src));
    }
    nfds = maxfd + 1;

    timeout.tv_sec  = 3;
    timeout.tv_usec = 0;

    // fd set
    FD_ZERO (&r_fds);
    static foreach (src; srcs) {
        static if (trait_has_fd!(typeof(src))) {
            FD_SET (src.fd,&r_fds);
        }
        else
        static if (trait_iterable_has_fd!(typeof(src))) {
            pragma (msg, "has FD: ", __traits(fullyQualifiedName,typeof(src)));
            foreach (ref e; src)
                FD_SET (e.fd,&r_fds);
        }
    }

    log (nfds);
    log (r_fds);

    // returns number of file descriptors of r_fds, _w_fds, _e_fds
    auto ret = select (nfds,&r_fds,null,null,&timeout);

    //
    if (ret == _SELECT_ERROR) {
        //on_error ();
        throw new Errno_exception ("select");
    }
    else 
    if (ret == _SELECT_TIMEOUT) {
        //on_timeout ();
        log ("on_timeout ()");
    }
    else { // OK
        // test set
        static foreach (src; srcs) {
            static if (trait_has_fd!(typeof(src))) {
                if (FD_ISSET (src.fd,&r_fds)) {
                    log (__traits (fullyQualifiedName,typeof(src)));
                    src.on_select ();
                }
            }
            else
            static if (trait_iterable_has_fd!(typeof(src))) {
                foreach (ref e; src)
                    if (FD_ISSET (e.fd,&r_fds)) {
                        log (__traits (fullyQualifiedName,typeof(e)));
                        e.on_select ();
                    }
            }
        }
    }
}

bool
trait_t_or_e_has_fd (S) () {
    static foreach (T;S)
        if (!(trait_has_fd!T && trait_iterable_has_fd!T))
            return false;
    return true;
}

template 
trait_has_fd (T) {
    //alias FD = int;
    static if (__traits (hasMember,T,"fd") && is (typeof (__traits (getMember,T,"fd")) == FD))
        enum trait_has_fd = true;
    else
        enum trait_has_fd = false;
}

template
trait_iterable_has_fd (T) {
    alias E = trait_elem_type!T;
    alias trait_iterable_has_fd = trait_has_fd!E;
}

template 
trait_elem_type (R) {
    static if (is(R : E[], E))
        alias trait_elem_type = E;
    else
        alias trait_elem_type = void;
}




// File
// Unix_Socket_File
// Select
//
// Select
//   File, Unix_Socket_File
//
// Select
//   r_fds[]
//   w_fds[]
//   e_fds[]
//   r_dg[]
//   w_dg[]
//   w_dg[]
//
//   select ()
//     on r_fds
//       r_dg ()
//     on w_fds
//       w_dg ()
//     on e_fds
//       e_dg ()

