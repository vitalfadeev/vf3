import regex_cmd;
import my_string;
import log : log;

struct
Db {
    Regex_cmd[] s;

    alias DB_IDX = size_t;

    Sorted_globs!DB_IDX by_glob;
    Sorted_regex!DB_IDX by_regex;
    Sorted_mimes!DB_IDX by_mime;
    Sorted_file!DB_IDX  by_file;
    // *.mp4 mpv $URL
    // regex cmd

    void
    seach (string q) {
        DB_IDX[] idxs;
        idxs ~= by_glob.get (q);
        idxs ~= by_regex.get (q);
        //idxs ~= by_mime.get (q);
    }

    void
    load () {
        import std.file;
        import std.string;
        import std.path;
        import my_string;

        string data;
        DB_IDX i;

        // read files
        foreach (string file_name; dirEntries ("files/", SpanMode.shallow)) {
            // read file
            read_file (file_name,data);

            //
            string name = file_name.baseName;

            // parse
            foreach (ref e; Parser (data)) {
                log (name,": ",e);

                // convert commands
                string[] cmds;
                foreach (_e; e.commands)
                    cmds ~= _e.s;

                // convert regexes
                string[] rgxs;
                foreach (_e; e.regexes)
                    rgxs ~= _e.s;

                s ~= Regex_cmd (name,rgxs,cmds);
                by_file.s[name][i] = _stub();

                // sort by regex type
                foreach (ref er; e.regexes) {
                    string regex = er.s;
                    auto my_string_mask = My_string_mask (regex);
                    auto cleaned = my_string_mask.cleaned ();
                    switch (my_string_mask.get_type) {
                        case My_string_mask.Type.GLOB  : by_glob.s[cleaned][i] = _stub(); break;
                        case My_string_mask.Type.REGEX : by_regex.s[cleaned][i] = _stub(); break;
                        case My_string_mask.Type.MIME  : by_mime.s[cleaned][i] = _stub(); break;
                        default:
                    }
                }

                i++;
            }
        }
    }

    void
    read_file (string file_name, ref string data) {
        import std.file;
        data = readText (file_name);
    }
}

struct
Parsed_data {
    // regexp,comment,short_menu_name,full_menu_name,command
    string regex;
    string name; // short_menu_name;
    string description;
    string icon;
    string hotkey;
    string command;
}

struct
Parser {
    import std.range;
    import std.traits;

    string s;

    alias E = _SAE_analyzer!(_String_analyzer!(string[])).Event; // String_analyzer.Event;

    alias DG = int delegate (ref E e);

    int 
    opApply (scope DG dg) {
        import std.range;
        import std.array;
        import std.string;

        string[] ss;
        foreach (_s; s.lineSplitter)
            ss ~= _s;

        foreach (ref e; ss.String_analyzer.SAE_analyzer) {
            int result = dg (e);

            if (result)
                return result;
        }

        return 0;
    }
}

auto SAE_analyzer (Range) (Range range) {
    return _SAE_analyzer!Range (range);
}

struct
_SAE_analyzer (R) {
    import std.range;
    import std.traits;

    R s;

    alias E = ElementType!R; // String_analyzer.Event;

    this (R range) {
        s = range;
    }

    Event
    front() @property {
        return Event ();
    }

    alias DG = int delegate (ref Event e);

    int 
    opApply (scope DG dg) {
        import std.string;

        Analyzer analyzer;
        analyzer.open ();

        foreach (ref e; s) {
            int result = analyzer.go (e,dg);

            if (result)
                return result;
        }

        // chek last element
        //   emit event
        return analyzer.close (dg);
    }

    struct
    Analyzer {
        int delegate (ref E e, scope DG dg) _analyze;

        Event _event;

        void
        open () {
            _analyze = &_analyze_start;
        }

        int
        go (ref E e, scope DG dg) {
            return _analyze (e,dg);
        }

        int
        close (scope DG dg) {
            return _analyze_finish (dg);
        }

        //
        alias _analyze_start = _analyze_in_level_0;

        int
        _analyze_in_level_0 (ref E e, scope DG dg) {
            switch (e.type) {
                case E.Type.LEVEL_0: 
                    _event.regexes ~= e;
                    _event.type = Event.Type.BLOCK;
                    break;
                case E.Type.LEVEL_1: 
                    _event.commands ~= e;
                    _analyze = &_analyze_in_level_1;
                    break;
                case E.Type.COMMENT: 
                    break;
                default:
            }
        
            return 0;
        }

        int
        _analyze_in_level_1 (ref E e, scope DG dg) {
            switch (e.type) {
                case E.Type.LEVEL_0: 
                    _analyze_finish (dg);
                    _event = _event.init;
                    _event.regexes ~= e;
                    _analyze = &_analyze_in_level_0;
                    break;
                case E.Type.LEVEL_1: 
                    _event.commands ~= e;
                    break;
                case E.Type.COMMENT: 
                    break;
                default:
            }
        
            return 0;
        }

        int
        _analyze_finish (scope DG dg) {
            if (_event.type != Event.Type._)
                return dg (_event);
            return 0;
        }
    }

    struct 
    Event {
        Type type;
        E[] regexes;
        E[] commands;

        enum Type {
            _,
            BLOCK,
        }
    }
}


auto String_analyzer (Range) (Range range) {
    return _String_analyzer!Range (range);
}

struct
_String_analyzer (R)  {
    import std.range;
    import std.traits;

    R s;

    alias E = ElementType!R; // String_analyzer.Event;

    this (R range) {
        s = range;
    }

    Event
    front() @property {
        return Event ();
    }

    alias DG = int delegate (ref Event e);

    int 
    opApply (scope DG dg) {
        import std.string;

        foreach (ref e; s) {
            int result = _analyze (e,dg);

            if (result)
                return result;
        }

        return 0;
    }

    int
    _analyze (E line, scope DG dg) {
        if (_is_comment (line)) {
            auto e = Event (Event.Type.COMMENT,line);
            return dg (e);
        }
        if (_is_level_0 (line)) {
            auto e = Event (Event.Type.LEVEL_0,line);
            return dg (e);
        }
        if (_is_level_1 (line)) {
            auto e = Event (Event.Type.LEVEL_1,line);
            return dg (e);
        }
        return 0;
    }

    bool
    _is_comment (string line) {
        import std.string;
        if (line.startsWith ("//") || line.startsWith ("#") || line.startsWith ("\n")) 
            return true;
        return false;
    }

    bool
    _is_level_0 (string line) {
        import std.string;
        if (!_is_level_1 (line)) 
            return true;
        return false;
    }

    bool
    _is_level_1 (string line) {
        import std.string;
        if (line.startsWith (" ") || line.startsWith ("\t")) 
            return true;
        return false;
    }

    struct
    Event {
        Type type;
        E    s;

        enum Type {
            _,
            COMMENT,
            LEVEL_0,
            LEVEL_1,
        }
    }
}



// *.mp4
// regex:.*\.mp4
// video/mp4
// file:*.mp4
// file://*.mp4
//  -> checker
class Checker {
    bool
    check (string pattern, string s) {
        return false;
    }
}

// *.mp4
// file:*.mp4
// file://*.mp4
class
Checker_file : Checker {
    override
    bool
    check (string pattern, string s) {
        return false;
    }
}

// regex:.*\.mp4
class
Checker_regex : Checker {
    override
    bool
    check (string rs, string s) {
         //import std.regex;
         //auto r = regex (rs);

         //if (!matchFirst (s,r).empty)
         //    return true;
         //else
         //    return false;
             return false;
   }
}

// video/mp4
class
Checker_mime : Checker {
    override
    bool
    check (string mime, string s) {
         return false;
   }
}

// Parser
//   /\
//  A B C
// abcdefghj

// by_mime
//   db[mime][0..1] = commands
// by_ext
//   db[ext][0..1] = commands


struct _stub {}

struct
Sorted_globs (DB_IDX) {
    DB_IDX_SET[string] s;  // "*.mp4" -> [1,2,3]

    alias DB_IDX_SET = _stub[DB_IDX];

    DB_IDX[]
    get (string q) {
        import std.path;

        DB_IDX_SET set;

        log ("s.keys ():", s.keys ());
        log ("s[glob].keys ():", s["*.mp4"].keys ());

        foreach (glob; s.keys ())
            if (globMatch (q,glob))
                foreach (i; s[glob].keys ())
                    set [i] = _stub ();

        return set.keys ();
    }
}

struct
Sorted_regex (DB_IDX) {
    DB_IDX_SET[string] s;  // ".*\.mp4" -> [1,2,3]

    alias DB_IDX_SET = _stub[DB_IDX];

    DB_IDX[]
    get (string q) {
        import std.regex;

        DB_IDX_SET set;

        foreach (rs; s.keys ())
            if (!matchFirst (q,regex (rs)).empty)
                foreach (i; s[rs].keys())
                    set[i] = _stub ();

        return set.keys ();
    }
}

struct
Sorted_mimes (DB_IDX) {
    DB_IDX_SET[string] s;  // "video/mp4" -> [1,2,3]

    alias DB_IDX_SET = _stub[DB_IDX];

    DB_IDX[]
    get (string q) {
        import std.regex;
        import globals;

        DB_IDX_SET set;

        auto mime_type = Globals.mime_db.mime_type_for_file_name (q);

        log ("mime_type.name:",mime_type.name);

        if (mime_type !is null) {
            auto _set = (mime_type.name) in s;
            if (_set !is null)
                return _set.keys ();            
        }

        return [];
    }
}


struct
Sorted_file (DB_IDX) {
    DB_IDX_SET[string] s;  // "mpv_open" -> [1,2,3]

    alias DB_IDX_SET = _stub[DB_IDX];

    DB_IDX[]
    get (string q) {
        DB_IDX_SET set;

        auto _set = q in s;
        if (_set !is null)
            return _set.keys ();            

        return [];
    }
}
