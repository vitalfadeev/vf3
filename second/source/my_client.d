import std.socket;
import std.stdio;
alias log = writeln;


class
My_client : Client_socket_base {
    this (string socket_path) {
        super (socket_path);
    }

    override
    void
    on_data (string data) {
        size_t n;
        string[] variants;
        parse_answer (data, n, variants);
        process_answer (n, variants);        
    }

    void
    process_answer (size_t n, string[] variants) {
        import std.string;

        switch (n) {
            case 0 : on_0_answers (n,variants); break;
            case 1 : on_1_answers (n,variants); break;
            default: on_n_answers (n,variants); break;
        }
    }

    void
    on_0_answers (size_t n, string[] variants) {
        //
    }

    void
    on_1_answers (size_t n, string[] variants) {
        execute_command (variants[0]);
    }

    void
    on_n_answers (size_t n, string[] variants) {
        // menu
        //   get answer
        //     send answer
        //       get answer 2
        //         execute
        Menu (n,variants)
            .go (
                (done) {
                    writeln ("DONE");
                });
    }
}

struct
Menu {
    size_t   n;
    string[] variants;

    alias DONE_DG = void delegate (string s);

    void
    go (DONE_DG done_cb) {
        _show_menu (variants, done_cb);
    }

    void
    _show_menu (string[] lines, DONE_DG done_cb) {
        // show menu
        //   send lines to stdin
        //   menu
        //     read lines from stdin
        //     on_done
        //       send "event://./menu/done/./selected_item" to stdout
        import std.stdio;
        import std.string;
        import std.conv;
        import std.process;

        string[string] env;
        auto pipes = pipeProcess ("bin/menu", Redirect.stdin, env);

        foreach (line; lines)
            pipes.stdin.writeln (line);

        pipes.stdin.flush ();
        pipes.stdin.close ();

        string[] output;
        foreach (line; pipes.stdout.byLine)
            output ~= line.idup;

        if (output.length > 0) {
            _on_menu_data (output[0], done_cb);
        }
    }

    void
    _on_menu_data (string selected_item, DONE_DG done_cb) {
        done_cb (selected_item);
    }
}

class
Client_socket_base : Socket {
    string socket_path;
    char[1024] buffer;

    this (string socket_path) {
        this.socket_path = socket_path;
        super (AddressFamily.UNIX, SocketType.STREAM);
        //socket.setOption (SocketOptionLevel.SOCKET, SocketOption.REUSEADDR, true);

        try {
            log ("Connecting");
            this.connect (new UnixAddress (socket_path));
        } catch (Throwable e) {
            log (e);
        }
    }

    void
    go (string[] input) {
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


void
parse_answer (string lines, ref size_t n, ref string[] variants) {
    import std.range, std.string, std.uni, std.conv;

    foreach (i,line; lines.splitLines) {
        switch (i) {
        case 0: 
            n = std.conv.to!int (line.strip ());
            break;
        default:
            variants ~= line;
            break;
        }
    }
}

void
execute_command (string cmd) {
    import std.stdio;
    import std.string;
    import std.conv;
    import std.process;

    log ("pipeProcess");
    log (cmd);

    auto shell = environment.get ("SHELL", "/bin/bash");
    string[string] env;
    auto pipes = pipeProcess (shell, Redirect.stdin, env);

    pipes.stdin.writeln (cmd);

    pipes.stdin.flush ();
    pipes.stdin.close ();
}


// #!/bin/bash
// menu <<< EOT
//   copy_file_to
//   copy_to_clipboard
//   mpv_open
// EOT
//
// on menu done
//   $MENU_DONE_ITEM $URL

// #!/bin/bash
// async
//   menu <<< EOT
//     copy_file_to
//     copy_to_clipboard
//     mpv_open
//   EOT
//   .done
//     $MENU_DONE_ITEM $URL
//   .fail
//     exit 1

// C:
//   girls.mp4
// S:
//   3
//   copy_file_to
//   copy_to_clipboard
//   mpv_open
// C:
//   menu
//     copy_file_to
//     copy_to_clipboard
//     mpv_open
// S:
//   1
//   mpv_open
// C:
//   mpv_open $URL
// S:
//   1
//   mpv_open $URL [pid:3]

// C:
//   girls.mp4
// S:
//   3
//   copy_file_to
//   copy_to_clipboard
//   mpv_open
// S:
//   menu girls.mp4
//   menu [copy_file_to,copy_to_clipboard,mpv_open]
// S -> menu -> event: -> $MENU_ITEM
// S:
//   1
//   mpv_open
// S:
//   mpv_open $URL
// S:
//   1
//   mpv_open $URL [pid:3]

// C: *.mp4
// S: 2 [mpv_open,file_copy]
//    create_process (menu) -> C2
//    or C2 = use_started_service (menu)
//    2 [mpv_open,file_copy] -> stdin -> C2
//      C2 send event in socket S "event:/menu/done/query_id/selected_item"
// S: // wait 'event:/menu/done/query_id/selected_item'
//    done:
//      done
//    fail:
//      fail
//    other:
//      changed
// S: done
//      selected_item
//        new query
//          selected_item *.mp4

// menu
//   on done:
//     done (selected_item)
//   on fail:
//     fail
//     cancel
//     closed
//   on other:
//     changed (new_selected_item,old_seleted_item)

