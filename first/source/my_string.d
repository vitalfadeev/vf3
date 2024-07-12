import std.string;

struct
My_string {
    string s;

    Type
    get_type () {
        import std.string;

        if (s.startsWith ("file:"))
            return Type.GLOB;

        if (s.startsWith ("regex:"))
            return Type.REGEX;

        if (s.startsWith ("mime:"))
            return Type.MIME;

        return Type.TEXT;
    }

    bool
    match (MIME_DB) (ref My_string_mask mask,ref MIME_DB mime_db) {
        return mask.match!MIME_DB (this,mime_db);
    }

    enum Type {
        _,
        REGEX,
        GLOB,
        MIME,
        TEXT,
        FOLDER,
        FILE,
        PATH,
        URL,
    }
}


// *.mp4
// regex:.*\.mp4
// video/mp4
// file:*.mp4
// file:///*.mp4
//  -> checker
struct
My_string_mask {
    string s;

    bool
    match (MIME_DB) (My_string my_s,ref MIME_DB mime_db) {
        switch (get_type ()) {
            case Type.GLOB:
                // POSIX glob
                import std.path;
                if (globMatch (my_s.s,s))
                    return true;
                break;
            case Type.REGEX:
                // regex
                import std.regex;
                auto r = regex (s);

                if (!matchFirst (my_s.s,r).empty)
                    return true;
                break;
            case Type.MIME:
                // mime
                auto mime_type = mime_db.mime_type_for_file_name (my_s.s);

                import log : log;
                log (mime_type ? mime_type.name : "");

                string _s;
                _s = s["mime:".length..$];

                if (mime_type !is null && mime_type.name == _s)
                    return true;
                break;
            default:
        }

        return false;
    }

    Type
    get_type () {
        import std.string;

        // file:*.mp4
        // file://./*.mp4
        if (s.startsWith ("file:"))
            return Type.GLOB;

        // regex:.*\.mp4
        if (s.startsWith ("regex:"))
            return Type.REGEX;

        // video/mp4
        if (s.startsWith ("mime:"))
            return Type.MIME;

        // video/mp4
        if (s.startsWith ("text:"))
            return Type.TEXT;

        // *.mp4
        if (s.startsWith ("*"))
            return Type.GLOB;

        return Type._;
    }

    string
    cleaned () {
        switch (get_type) {
            case My_string_mask.Type.GLOB  : return s;
            case My_string_mask.Type.REGEX : return s["regex:".length..$];
            case My_string_mask.Type.MIME  : return s["mime:".length..$];
            case My_string_mask.Type.TEXT  : return s["text:".length..$];
            default: return s;
        }
    }

    enum Type {
        _,
        REGEX,
        GLOB,
        MIME,
        TEXT,
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

 