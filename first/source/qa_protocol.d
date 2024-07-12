import std.range;
import std.array;
import std.string;
import std.process;
import url;
import s;
import regex_cmd;
import globals;
import query_registry : Query_registry,Query_registry_rec,Query_id;
import log : log;


// mov_open:
// *.mp4
//   mpv $URL
//
// file_copy:
// *
//   cp $URL ...
//
// C: girls.mp4
// S: 2
// S: mpv_open
// S: file_copy
// C: mpv_open girls.mp4
// S: 1
// S: mpv_open girls.mp4 [pid:3]
// system ("mpv girls.mp4")

// b = protocol + a

struct
QA_protocol {
    string 
    q (string s) {
        auto url = parseURL (s);

        if (url.scheme == "event")
            return on_event (url);
        else
            return on_query (s);
    }

    string
    on_event (ref URL url) {
        if (url.path.startsWith ("/menu"))
            return on_menu_event (url);
        return "";
    }

    string
    on_menu_event (ref URL url) {
        if (url.path.startsWith ("/menu/done"))
            return on_menu_done_event (url);
        return "";
    }

    string
    on_menu_done_event (ref URL url) {
        import std.conv;

        auto splits = url.path.split ("/");  //   / menu / done / 3 / mpv_open
        auto qid = splits[3];                // 0   1      2      3   4
        auto selected_item = splits[4];
        log ("splits:",splits);

        Query_id query_id = Query_id (parse!(typeof(Query_id._a)) (qid));
        //Query_registry_rec rec;
        //if (query_registry.get (query_id, rec) ) {
        //    QA_protocol ().q (selected_item ~ " " ~ rec.query);
        //    //S s1;
        //    //auto cmd_string = s1.command_for_name (name);
        //    //if (cmd_string)
        //    //    auto pipes = pipeProcess (cmd_string);
        //}

        return "";
    }

    auto
    on_query (string s) {
        import std.string;
        import std.uni;

        auto splits = s.split (" ");
        log ("splits: ", splits);

        if (splits.length >= 2) {
            auto name = splits[0];
            auto arg  = splits[1..$].join (" ");
            foreach (c;name)
                if (c.isAlphaNum || c == '_' || c == '-')
                    continue;
                else
                    return client_say (s);

            return client_wait_commands_for (name,arg);
        }
        else
            return client_say (s);
    }

    string
    client_say (string s) {
        auto answers = S ().query (s);

        return answer_to_client (s,answers);
    }

    string
    client_wait_commands_for (string name, string arg) {
        import std.string;

        auto commands = S ().commands_for_name (name);
        string output = "1\n" ~ commands.join ("\n");
        return output;
    }

    string
    answer_to_client (string s, Regex_cmd[] answers) {
        switch (answers.length) {
            case 0:  return on_0_answer ();
            case 1:  return on_1_answer (s,answers);
            default: return on_n_answer (s,answers);
        }
    }

    string
    on_0_answer () {
        return "0\n";    
    }

    string
    on_1_answer (string s, Regex_cmd[] answers) {
        import std.string;

        string output = "1\n" ~ answers[0].commands.join ("\n");

        //execute_command (answer.commands, s);

        return output;
    }

    string
    on_n_answer (string s, Regex_cmd[] answers) {
        import std.conv;
        //show_menu (s,answers);
        string output;
        output ~= answers.length.to!string ~ "\n";
        foreach (ref a; answers)
            output ~= a.file_name ~ "\n";
        return output;
    }

    void
    show_menu (string s, Regex_cmd[] answers) {
        import std.stdio;
        import std.string;
        import std.conv;
        import std.process;

        // 2...
        //   menu
        //     stdin -> menu -> stdout -> menu_wrapper.socket
        //string query_id_s = query_id.to!string;
        string query_id_s = "1";
        string[string] env;
        env["VF_QUERY_STRING"] = s;
        env["VF_QUERY_ID"] = query_id_s;
        env["VF_EVENT_TPL"] = "event://./menu/done/"~query_id_s~"/";
        auto pipes = pipeProcess ("bin/menu", Redirect.stdin, env);

        foreach (ref a; answers)
            pipes.stdin.writeln (a.file_name);

        pipes.stdin.flush ();
        pipes.stdin.close ();
    }

    string
    execute_command (string name, string s) {
        auto commands = S ().commands_for_name (name);
        log ("commands:",commands);
        execute_command (commands, s);
        return "";
    }

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
