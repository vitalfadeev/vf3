import std.stdio;
import std.range : back;
import std.range : ElementType;
import bindbc.freetype;
alias log = writeln;


struct
Font_cache (Draws) {
    Fonts!Draws fonts;

    int font_dpi  = 96;

    auto
    get_draws (Fonts!Draws.Font_id font_id, Fonts!Draws.Font_size size, dchar index) {
        // if draws
        //   draws
        // else
        //   create from glyph
        //auto draws = draws[font][size][index];
        auto _font_rec = fonts.s[font_id];
        auto _chars = size in _font_rec.draws;
        if (_chars !is null) {
            auto _draws = index in *_chars;
            return *_draws;
        }
    
        auto ftface = _font_rec.ftface;

        auto glyph = get_glyph (ftface,size,index);
        auto _draws = draws_from_glyph (ftface,index);
        _font_rec.draws[size][index] = _draws;

        return _draws;
    }

    auto
    get_glyph (FT_Face ftface, int font_size, dchar index) {
        FT_Set_Char_Size (ftface, 0, font_size * 64, font_dpi, font_dpi);
        FT_Load_Glyph (ftface, FT_Get_Char_Index (ftface,index), FT_LOAD_DEFAULT);
        return ftface.glyph;
    }

    auto
    draws_from_glyph (FT_Face ftface, dchar index) {
        return Glyph_to_draws!Draws ().go (ftface);
    }
}


struct
Glyph_to_draws (Draws) {
    alias Point = ElementType!(typeof(Draws.Rec.points));
    alias SELF = typeof(this);

    Draws draws;
    FT_Outline_Funcs _callbacks = {
        &move_to_cb,
        &line_to_cb,
        &coni_to_cb,
        &cubi_to_cb
    };

    auto
    go (FT_Face ftface) {
        draws.s ~= Draws.Rec (Draws.Rec.Type.LINES);

        FT_Outline outline = ftface.glyph.outline;

        auto _err = FT_Outline_Decompose (&outline,&_callbacks,&this);
        
        if (_err)
            throw new Exception ("FT_Outline_Render");

        return draws;
    }

    extern (C)
    nothrow
    static
    int
    move_to_cb (const FT_Vector* to, void* _self) {
        auto self = cast (SELF*) (_self);

        //FT_Pos x = to.x / 64;
        //FT_Pos y = to.y / 64;

        //self.draws.s ~= E (E.Type.LINES);
        self.draws.s.back.points ~= Point (cast (int) to.x/64,cast (int) to.y/64);

        return 0;
    }

    extern (C)
    nothrow
    static
    int
    line_to_cb (const FT_Vector* to, void* _self) {
        auto self = cast (SELF*) (_self);

        self.draws.s.back.points ~= Point (cast (int) to.x/64,cast (int) to.y/64);

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

        self.draws.s.back.points ~= Point (cast (int) to.x/64,cast (int) to.y/64);

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

        self.draws.s.back.points ~= Point (cast (int) to.x/64,cast (int) to.y/64);

        return 0;
    }
}


struct
Fonts (Draws) {
    Rec[] s; // loaded_fonts

    alias Font_id = size_t;
    alias Font_size = byte;

    Font_id
    add (string font_name) {
        import std.algorithm.searching : countUntil;

        auto i = s.countUntil!"a.pathname==b" (font_name);

        if (i != -1)
            return i;

        s ~= Rec (font_name);

        return s.length - 1;
    }

    struct
    Rec {
        string  pathname;
        FT_Face ftface;
        Draws[dchar][Font_size] draws;
    }
}
