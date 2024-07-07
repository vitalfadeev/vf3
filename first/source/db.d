import regex_cmd;
import log : log;

struct
Db {
    Regex_cmd[] s;
    // *.mp4 mpv $URL
    // regex cmd

    void
    load () {
        import std.file;
        import std.string;
        import std.path;

        string data;

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
                foreach (_e;e.commands)
                    cmds ~= _e.s;
                // 1 regex - 1 record
                foreach (ref er;e.regexes) {
                    string regex = er.s;
                    s ~= Regex_cmd (name,regex,cmds);
                }
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


auto Parser2 (Range) (Range range) {
    return _Parser!Range (range);
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

// pattern
// bash pattern
// *  any string, null string
// ?  single char
// [] any one of enclosed chars, [!...] not chars, [^...] not chars, [a-d] = [abcd], 
//    [:class:] class one of POSIX classes: alnum alpha ascii blank cntrl digit graph lower print punct space upper word xdigit
//    [=c=]
//    [.symbol.]
//
// ?(pattern-list)
// *(pattern-list)
// +(pattern-list)
// @(pattern-list)
// !(pattern-list)
// pattern-list = pattern|pattern|pattern
//   std.path. globMatch (s,"*.mp4")

