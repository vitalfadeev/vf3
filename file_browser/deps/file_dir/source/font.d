import std.range : back;
import std.stdio : writeln;
import std.string : toStringz,fromStringz;
import bindbc.loader;
import bindbc.freetype;
//import file;
import errno_exception;
alias log=writeln;



struct
Font (alias FT_Library ftLib) {
    //File _super;
    //alias _super this;

    static
    ID
    open (string pathname) {
        return ID (pathname);
    }

    struct
    ID {
        FT_Face _fd;
        alias _fd this;
        alias ftface = _fd;

        this (string pathname) {
            auto error = FT_New_Face (ftLib,pathname.toStringz,0,&ftface);

            if (error == FT_Err_Unknown_File_Format) {
                //... the font file could be opened and read, but it appears
                //... that its font format is unsupported
            }
            else 
            if (error) {
                //... another error code means that the font file could not
                //... be opened or read, or that it is broken...
            }
        }

        Font_Size.ID
        open (int size) {
            return Font_Size.open (_fd,size);
        }
    }
}

unittest {
    //
}

struct
Font_Size {
    enum font_dpi  = 96;

    static
    ID
    open (FT_Face ftface, int size) {
        return ID (ftface,size);
    }

    struct
    ID {
        FT_Face _fd;
        int     _size;
        alias ftface = _fd;

        this (FT_Face ftface, int size) {
            this._fd   = ftface;
            this._size = size;
            FT_Set_Char_Size (ftface, 0, size * 64, font_dpi, font_dpi);
        }

        Font_Glyph.ID
        open (dchar index) {
            return Font_Glyph.open (ftface,_size,index);
        }
    }
}


struct
Font_Glyph {
    static
    ID
    open (FT_Face ftface, int size, dchar index) {
        return ID (ftface,size,index);
    }

    struct
    ID {
        dchar   index;
        FT_Face ftface;
        int     size;
        alias _fd = index;

        this (FT_Face ftface, int size, dchar index) {
            this.index  = index;
            this.ftface = ftface;
            this.size   = size;
            FT_Load_Glyph (ftface, FT_Get_Char_Index (ftface,index), FT_LOAD_DEFAULT);
        }

        Iterator!E
        read (E) () {  // conturs
            return Iterator!E (ftface,size);
        }

        struct
        E {
            Type    type;
            Point[] points;  // rel

            enum Type {
                POINTS,
                LINES,
                LINES2,
            }

            struct 
            Point {  // SDL_Point
                int x;
                int y;
            }
        }

        struct
        Iterator (E) {
            FT_Face ftface;
            int     size;
            Glyph_to_points!E gp;

            alias DG = int delegate (E e);

            E front () { return E ();};

            int 
            opApply (scope DG dg) {
                gp.go (ftface,size);

                foreach (e; gp.s) {
                    int result = dg (e);

                    if (result)
                        return result;
                }

                return 0;
            }    
        }
    }
}

struct
Glyph_to_points (E) {
    E[] s;
    int size;
    alias SELF = typeof(this);
    
    FT_Outline_Funcs _callbacks = {
        &move_to_cb,
        &line_to_cb,
        &coni_to_cb,
        &cubi_to_cb
    };

    auto
    go (FT_Face ftface, int size) {
        this.size = size;
        FT_Outline outline = ftface.glyph.outline;

        auto _err = FT_Outline_Decompose (&outline,&_callbacks,&this);
        
        if (_err)
            throw new Exception ("FT_Outline_Render");
    }

    extern (C)
    nothrow
    static
    int
    move_to_cb (const FT_Vector* to, void* _self) {
        auto self = cast (SELF*) (_self);

        //FT_Pos x = to.x / 64;
        //FT_Pos y = to.y / 64;

        self.s ~= E (E.Type.LINES);
        self.s.back.points ~= E.Point (cast (int) to.x/64,self.size-cast (int) to.y/64);

        return 0;
    }

    extern (C)
    nothrow
    static
    int
    line_to_cb (const FT_Vector* to, void* _self) {
        auto self = cast (SELF*) (_self);

        self.s.back.points ~= E.Point (cast (int) to.x/64,self.size-cast (int) to.y/64);

        return 0;
    }

    extern (C)
    nothrow
    static
    int
    coni_to_cb (const FT_Vector* control, const FT_Vector* to, void* _self) {
        auto self = cast (SELF*) (_self);

        FT_Pos controlX = control.x;
        FT_Pos controlY = control.y;

        self.s.back.points ~= E.Point (cast (int) to.x/64,self.size-cast (int) to.y/64);

        return 0;
    }

    extern (C)
    nothrow
    static
    int
    cubi_to_cb (const FT_Vector* controlOne,
                    const FT_Vector* controlTwo,
                    const FT_Vector* to,
                    void *_self) {
        auto self = cast (SELF*) (_self);

        FT_Pos controlOneX = controlOne.x;
        FT_Pos controlOneY = controlOne.y;

        FT_Pos controlTwoX = controlTwo.x;
        FT_Pos controlTwoY = controlTwo.y;

        self.s.back.points ~= E.Point (cast (int) to.x/64,self.size-cast (int) to.y/64);

        return 0;
    }
}


//  "arial.ttf/10"
// ("arial.ttf", 10)

// Resource
//   open ("arial.ttf/10")
//   open ("arial.ttf", 10)

//   read () -> iterator

//   open ("arial.ttf").open (10)

//   open ("arial.ttf").open (10).open ('A')
//   open ("arial.ttf").open (10).open ('A').read ()

unittest {
    load_FT ();
    init_ft ();

    string  pathname  = "/usr/share/fonts/truetype/noto/NotoSansMono-Regular.ttf";
    int     size = 64;

    auto r = Font.open (pathname).open (size).open ('A').read!(Font_Glyph.ID.E) ();
    
    foreach (e; r)
        log (e);

    void
    load_FT () {
        /*
        This code attempts to load the FreeType shared library using
        well-known variations of the library name for the host system.
        */
        auto ret = loadFreeType ();
        if (ret != ftSupport) {
            import bindbc.loader;
            import core.stdc.stdio: printf;
            foreach (error; errors){
                    printf ("%s: %s\n", error.error, error.message);
            }
            return;
        }

        // static lib bindings
        //FT_Library lib;
        //FT_Init_FreeType (&lib);    
    }

    FT_Library ftLib;

    void
    init_ft () {
        FT_Error err;
        err = FT_Init_FreeType (&ftLib);
        if (err) {
            log (FT_Error_String (err));
            throw new Exception ("Loading error: ");
        }

        int maj, min, pat;
        FT_Library_Version (ftLib, &maj, &min, &pat);
        assert (maj >= 2);
        assert (min >= 13);
    }
}

