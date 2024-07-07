import db;
import regex_cmd;
import log : log;

struct 
S {
    Regex_cmd[]
    query (string s) {
        // *.mp4 mpv $URL
        Db db;
        db.load ();

        Regex_cmd[] rcs;

        foreach (ref rc; db.s) {
            if (check (rc, s))
                rcs ~= rc;
        }

        return rcs;
    }

    bool
    check (ref Regex_cmd rc, string s) {
        import std.string;
        //return checker.check (rc.regex_string, s);
        if (rc.regex_string.startsWith ("*")) {
            // POSIX glob
            import std.path;
            if (globMatch (s,rc.regex_string))
                return true;
        }
        else {
            // regex
            import std.regex;
            auto r = regex (rc.regex_string);

            if (!matchFirst (s,r).empty)
                return true;
        }

        return false;
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
        Db db;
        db.load ();

        Regex_cmd[] rcs;

        foreach (ref rc; db.s) {
            if (check (rc, name))
                rcs ~= rc;
        }

        foreach (ref rc; rcs)
            if (rc.file_name == name)
                return rc.commands;

        return null;
    }
}
