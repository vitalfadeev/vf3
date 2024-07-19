import regex_cmd;
import my_string;
import globals;
import log : log;


struct 
S {
    Regex_cmd[]
    query (string q) {
        // 1.mp4

        // by_glob
        auto idxs = Globals.db.by_glob.get (q);
        log ("by_glob:",idxs);

        // by_mime
        auto idxs2 = Globals.db.by_mime.get (q);
        log ("by_mime:",idxs2);

        // 1 -> Regex_cmd
        Regex_cmd[] rcs;
        foreach (i; idxs)
            rcs ~= Globals.db.s[i];
        foreach (i; idxs2)
            rcs ~= Globals.db.s[i];

        return rcs;
    }

    string
    replace_vars (string s, string url) {
        import std.array;
        import std.string;
        auto news = s.replace ("$URL", url);
        return news;
    }

    string[]
    commands_for_name (string name) {
        Regex_cmd[] rcs;

        auto ids = Globals.db.by_file.get (name);  // [1,2,3]

        foreach (i; ids)
            rcs ~= Globals.db.s[i];

        foreach (rc; rcs)
            return rc.commands;

        return [];
    }
}
