import std.stdio : writeln;

struct
Links {
    Link_set[Id] s;  // sorted by a

    Lazy_iterator
    query (ref string[] strings) {
        // *.mp4 ? mpv -> open
        // mpv ? -> open
        // mpv open ? -> mp4
        auto q = ["*.mp4", "?", "mpv"];
        return Lazy_iterator ();
    }

    Lazy_iterator
    query (Id a) {
        return Lazy_iterator ();
    }

    Lazy_iterator
    query (Id a, Id b) {
        return Lazy_iterator ();
    }
}

alias Id = int;  // offset in file. When delete: mark "deleted". When rename: delete and add new.
alias Name = string;

struct
Link_set {
    Unit[Id] s;

    alias Unit = void[0];
    enum unit = Unit.init;

    void
    opOpAssign (string op : "~") (Id b) {
        s[b] = unit;
    }
}

struct
Ids {
    static Id id;

    static
    auto
    get_new () {
        id += 1;
        return id;
    }

    static
    auto
    get_last () {
        return id;
    }
}

struct
Lazy_iterator {
    // foreach () able
    // .each () able
}

struct
Links_file {
    Links _links;  // sorted by a
    string file_name = "links.txt";
    Id[string] _names;

    void
    read () {
        import std.file : readText, exists;

        string _s;
        if (file_name.exists ()) {
            import std.stdio : File;
            import std.string : split;
            import std.uni : isWhite;

            auto file = File (file_name);
            foreach (ref line; file.byLine ) {
                // strings
                // find in names
                //   names [a] ~= b
                // else
                //   names ~= s
                Id _prev_id;
                foreach (_name; line.split!isWhite ()) {
                    Id _id;

                    // name, id
                    if (_name in _names) {
                        _id = _names[_name];
                    }
                    else {
                        string _tmp_name = _name[0 .. _name.length].idup;
                        _id = Ids.get_new ();
                        _names [_tmp_name] = _id;
                    }

                    // link
                    if (_prev_id != 0) {
                        if (_prev_id in _links.s)
                            _links.s[_prev_id] ~= _id;
                        else {
                            _links.s[_prev_id] = Link_set ();
                            _links.s[_prev_id] ~= _id;
                        }
                    }

                    //
                    _prev_id = _id;
                }
            }
        }
    }

    void
    write () {
        //
    }
}

struct
Names_file {
    string s;
    string file_name = "names.txt";

    void
    read () {
        import std.file : readText, exists;
        if (file_name.exists ())
            s = file_name.readText ();
        else
            s = "";
    }

    void
    write () {
        import std.file : write;
        file_name.write (s);
    }
}

struct
Names {
    Name[] s;
}


/*
# open
*.mp4 open mpv

## links
mp4 - open - mpv

## config
what       what
      link
----- ---- ----
*.mp4 open mpv

what       what
  link   link
      what
----- ---- ----
*.mp4 open mpv

*.mp4 - open - mpv

mpv.ini
[open]
*.mp4

query
  *.mp4 ? mpv -> open
  mpv ? -> open
  mpv open ? -> mp4

## click in file manager
file.mp4 ? -> open
  file.mp4 open -> mpv
*/
