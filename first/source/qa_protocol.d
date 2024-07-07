import std.range;
import std.array;
import std.string;
import std.process;
import url;
import s;
import regex_cmd;
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
        return client_say (s);
    }

    string
    client_say (string s) {
        S s1;
        auto answers = s1.query (s);

        return answer_to_client (s,answers);
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
        string output = "1\n";

        auto answer = answers[0];
        output ~= answer.file_name ~ "\n";

        execute_command (answer.commands, s);

        return output;
    }

    string
    on_n_answer (string s, Regex_cmd[] answers) {
        show_menu (s,answers);
        return "";
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
        auto pipes = pipeProcess (shell, Redirect.stdin, env);

        foreach (cmd;cmd_lines)
            pipes.stdin.writeln (cmd);

        pipes.stdin.flush ();
        pipes.stdin.close ();
    }
}
