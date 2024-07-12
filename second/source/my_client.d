import std.socket;
import std.stdio;
import async_command_socket;
import my_menu_server;
import client_socket_base;
alias log = writeln;


class
My_client : Client_socket_base {
    string[] args;

    this (string socket_path) {
        super (socket_path);
    }

    override
    void
    go (string[] args) {
        this.args = args;
        super.go (args);
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
        execute_command (variants, args[0]);
    }

    void
    on_n_answers (size_t n, string[] variants) {
        // menu
        //   get answer
        //     send answer
        //       get answer 2
        //         execute
        Menu_async (n,variants)
            .go (
                (done) {
                    log ("DONE");
                    import std.string;
                    auto splits = done.split ("/")[3];
                    if (splits.length >= 4) {
                        string cmd = done.split ("/")[3];
                        //execute_command ([cmd]);
                        log (cmd);
                        query_command (cmd ~ " " ~ args[0]);
                    }
                });
    }

    void
    query_command (string cmd) {
        import std.string;

        this.write (cmd);

        string buffer = this.read ();
        log ("buffer:",buffer);

        if (buffer !is null) {
            on_data (buffer);
        }
    }

    //void
    //execute_command (ref string[] cmd) {
    //    log (cmd);
    //    this.write (cmd ~ " " ~ args[0]);
    //}

    void
    execute_command (string[] cmd_lines, string s) {
        import std.stdio;
        import std.string;
        import std.conv;
        import std.process;

        log ("pipeProcess");
        log (cmd_lines);

        auto shell = environment.get ("SHELL", "/bin/bash");
        string[string] env;
        env["URL"] = s;
        auto pipes = pipeProcess (shell, Redirect.all, env);

        foreach (cmd;cmd_lines)
            pipes.stdin.writeln (cmd);

        pipes.stdin.flush ();
        pipes.stdin.close ();

        wait (pipes.pid);

        foreach (_out;pipes.stdout.byLine)
            log (_out);
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
        auto pipes = pipeProcess ("../first/bin/menu", Redirect.stdin | Redirect.stdout, env);

        foreach (line; lines)
            pipes.stdin.writeln (line);

        pipes.stdin.flush ();
        pipes.stdin.close ();

        wait (pipes.pid);

        string[] output;
        foreach (line; pipes.stdout.byLine)
            output ~= line.idup;

        if (output.length > 0)
            _on_menu_data (output[0], done_cb);
    }

    void
    _on_menu_data (string selected_item, DONE_DG done_cb) {
        done_cb (selected_item);
    }
}

struct
Menu_async {
    size_t   n;
    string[] variants;

    alias DONE_DG = void delegate (string s);

    void
    go (DONE_DG done_cb) {
        _show_menu_async (variants, done_cb);
    }

    void
    _show_menu_async (string[] lines, DONE_DG done_cb) {
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
        import std.file;

        string vf_menu_async_socket = "/tmp/vf_menu_async.soc";
        if (vf_menu_async_socket.exists)
            vf_menu_async_socket.remove ();
        auto my_menu_server = new My_menu_server (vf_menu_async_socket);
        my_menu_server.done_cb = done_cb;

        string[string] env;
        env["VF_SOCKET_PATH"] = vf_menu_async_socket;
        auto pipes = pipeProcess ("/home/vf/src/vf3/first/bin/menu_async", Redirect.all, env);

        foreach (line; lines)
            pipes.stdin.writeln (line);

        pipes.stdin.flush ();
        pipes.stdin.close ();

        my_menu_server.go ();

        wait (pipes.pid);
    }

    void
    _on_menu_data (string selected_item, DONE_DG done_cb) {
        done_cb (selected_item);
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
__execute_command (string cmd) {
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

