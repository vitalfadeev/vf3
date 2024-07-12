module unix_socket.poll;

import std.stdio : writeln;
alias log=writeln;

struct 
Poll {
    File[] files;
    DG[]   dg;

    pollfd[] _fds;

    alias DG = void delegate (File fd);

    // #include <sys/select.h>
    // #include <sys/time.h>
    // #include <sys/types.h>
    // #include <unistd.h>

    import core.sys.posix.poll : 
        poll,pollfd,POLLIN,POLLRDNORM,POLLRDBAND,POLLPRI,
        POLLOUT,POLLWRNORM,POLLWRBAND,POLLERR,POLLHUP,POLLNVAL;

    void
    go () {
        int nfds = cast (int) files.length;
        int timeout;

        timeout = 3 * 1000;

        _fds.length = nfds;

        foreach (i,ref f; files) {
            _fds[i].fd     = f.fd;
            _fds[i].events = POLLIN;
        }

        log (nfds);
        log (_fds);

        // returns number of file descriptors of _r_fds, _w_fds, _e_fds
        // poll
        //   /dev/input/eventN  // can read ()               // File
        //   /tmp/vf.soc        // new_client_fd = accept () // Server
        //     client_fd        // can recv ()               //   Client
        //     client_fd        // can recv ()               //   Client
        // Poll (file,server), Select (file,server)
        // Poll
        //   File                     file_dev_input_event
        //   Local_socket             server
        //   Client_of_local_socket[] clients
        auto ret = poll (_fds.ptr,nfds,timeout);

        //
        if (ret == -1) {
            on_error ();
        }
        else 
        if (ret) {
            // auto client = server.accept();
            // if client
            //   clients ~= client;
            // foreach (client; clients)
            //   recv
            foreach (i,ref pfd; _fds)
                if (pfd.revents != 0) {
                    if (pfd.revents & POLLIN)  {}
                    if (pfd.revents & POLLHUP) {}
                    if (pfd.revents & POLLERR) {}

                    if (pfd.revents & POLLIN) {
                        dg[i] (files[i]);
                        on_data ();
                    }
version (__) {
                    if (pfd.fd == listen_sd) {
                        do {
                            log ("Listening socket is readable");
                            auto new_sd = accept (listen_sd,null,null);
                            if (new_sd < 0) {
                                if (errno != EWOULDBLOCK) {
                                    log ("  accept() failed");
                                    end_server = TRUE;
                                }
                                break;
                            }
                            log ("  New incoming connection - %d", new_sd);
                            fds[nfds].fd = new_sd;
                            fds[nfds].events = POLLIN;
                            nfds++;
                        } while (new_sd != -1);
                    }
                    else {
                        log ("  Descriptor %d is readable", fds[i].fd);
                        close_conn = FALSE;
                        do {
                            rc = recv (fds[i].fd, buffer, sizeof(buffer), 0);
                            if (rc < 0) {
                                if (errno != EWOULDBLOCK) {
                                    log ("  error: recv() failed");
                                    close_conn = TRUE;
                                }
                                break;
                            }
                            if (rc == 0) {
                                log ("  Connection closed");
                                close_conn = TRUE;
                                break;
                            }
                            
                            len = rc;
                            log ("  %d bytes received", len);

                            rc = send (fds[i].fd, buffer, len, 0);
                            if (rc < 0) {
                                log ("  send() failed");
                                close_conn = TRUE;
                                break;
                            }
                        } while (true);

                        if (close_conn) {
                            close (fds[i].fd);
                            fds[i].fd = -1;
                        }
                    }
}
                }
        }
        else {
            on_timeout ();
        }
    }

    void
    on_data () {
        log ("on_data");
    }

    void
    on_error () {
        log ("error: select()");
    }

    void
    on_timeout () {
        log ("timeout: No data within N seconds.");
    }
}

struct 
File {
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

    public import core.sys.posix.fcntl : open;
    public import core.sys.posix.unistd : close;

    alias FD = int;

    FD     fd;
    string pathname;

    this (FD fd) {
        this.fd = fd;
    }

    this (string pathname) {
        this.pathname = pathname;
    }

    void
    open (int flags) {
        import std.string : toStringz;

        auto _fd = open (pathname.toStringz,flags);

        if (_fd == -1)
            on_error ();
        else
            fd = _fd;
    }

    void
    open (int flags, mode_t mode) {
        import std.string : toStringz;

        auto _fd = open (pathname.toStringz,flags,mode);

        if (_fd == -1)
            on_error ();
        else
            fd = _fd;
    }

    void 
    close () {
        close (fd);
    }

    TREAD
    read (TREAD) (ref TREAD buf) {
        import core.sys.posix.unistd : read;
        //TREAD buf;
        auto n = read (fd, &buf, buf.sizeof);
        if (n == -1) {
            throw new Exception ("error: read: "~pathname);
        }
        else {
            return buf;
        }
    }

    void
    on_error () {
        import unix_socket.errno_exception : format_error;
        import core.sys.linux.errno : errno;
        log ("error: ",format_error (errno));
    }
}


struct
Socket_File {
    File file;
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

