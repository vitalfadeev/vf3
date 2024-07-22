import bindbc.sdl;
import std.range : ElementType;
import types;
import std.stdio : writeln;
alias log = writeln;


struct
GL_Side {
    // Resources
    //   ( (type,points[]) [] ) [id]   <- for char
    //   type,points
    //   type,rel_points  // Bytes
    //
    //   (move,id) []
    //   (abs_move_pos,id) []          <- for string
    //    
    alias ID = dchar;

    SDL_Renderer* renderer;
    _mix[ID]      s;  // resources


    alias ABSXY = SDL_Point;
    alias RELXY = SDL_Point;

    //struct
    //ABSXY {  // 16,16
    //    short x;
    //    short y;
    //}

    //struct
    //RELXY {  // 8,8
    //    byte x;
    //    byte y;
    //}

    void
    draw (ID id) {
        _draw_mix (id);
    }

    void
    load_font_resource () {
        //
    }

    void
    load_image_resource () {
        //
    }

    void
    draw_char (ID id, _char draws) {
        _add_char (id,draws);
        _draw_draws (draws);
    }

    void
    draw_string (ID[] ids, ABSXY[] xys) {
        _add_string (ids,xys);
        //_draw_draws (draws);
    }

    void
    _add_char (ID char_id, _char draws) {
        s[char_id] = _mix ([_mix.Rec (_mix.Rec.Type.CHAR, draws)]);
    }

    void
    _add_string (ID[] ids, ABSXY[] xys) {
        _string.Rec[] recs;
        recs.length = ids.length;

        foreach (i,id; ids)
            recs[i] = _string.Rec (xys[i],id);

        _add_string (recs);
    }

    void
    _add_string (_string.Rec[] recs) {
        ID char_id = _new_id ();
        s[char_id] = _mix ([_mix.Rec (_mix.Rec.Type.STRING, _string (recs))]);
    }

    ID
    _new_id () {
        static ID _last_id;
        _last_id++;
        return _last_id;
    }

    void 
    _draw_mix (ID id) {
        auto m = id in s;

        if (m !is null) {
            _draw_mix (m);
        }
    }

    void 
    _draw_mix (_mix* m) {
        foreach (ref rec; m.s) {
            switch (rec.type) {
                case _mix.Rec.Type.CHAR:   _draw_char   (&rec.c); break;
                case _mix.Rec.Type.STRING: _draw_string (&rec.s); break;
                default:
            }
        }
    }

    void
    _draw_char (ID char_id) {
        auto m = _get_char_draws (char_id);
        if (m !is null) {
            _draw_mix (m);
        }
    }

    void 
    _draw_char (_char* cc) {
        _draw_draws (*cc);
    }

    void 
    _draw_string (_string* ss) {
        foreach (ref rec; ss.s) {
            _move_g_cursor (rec.abs_move_pos);
            _draw_char (rec.c);
        }
    }

    void
    _move_g_cursor (ABSXY pos) {
        // pos
    }

    void
    __draw_draws (R) (R range) {
        alias E = ElementType!R;

        foreach (e; range) 
            final
            switch (e.type) {
                case E.Type.POINTS: 
                    SDL_RenderDrawPoints (renderer,e.points.ptr,cast (int) e.points.length);
                    break;
                case E.Type.LINES: 
                    SDL_RenderDrawLines (renderer,e.points.ptr,cast (int) e.points.length);
                    break;
                case E.Type.LINES2: 
                    // ...
                    break;
            }
    }

    void
    _draw_draws (_char draws) {
        foreach (ref rec; draws.s) 
            switch (rec.type) {
                case _char.Rec.Type.POINTS: 
                    SDL_RenderDrawPoints (renderer,rec.points.ptr,cast (int) rec.points.length);
                    break;
                case _char.Rec.Type.LINES: 
                    SDL_RenderDrawLines (renderer,rec.points.ptr,cast (int) rec.points.length);
                    break;
                case _char.Rec.Type.LINES2: 
                    break;
                default:
            }
    }

    _mix*
    _get_char_draws (ID char_id) {
        return char_id in s;
    }

    //SDL_Point[]
    //to_sdl_points (RELXY[] points) {
    //    SDL_Point[] sdl_points;
    //    sdl_points.length = points.length;

    //    foreach (i,p; points) 
    //        sdl_points[i] = SDL_Point (p.x,p.y);

    //    return sdl_points;
    //}

    struct
    _char {
        Rec[] s;

        struct 
        Rec {
            Type    type;
            RELXY[] points;  // rel

            enum Type {
                POINTS,
                LINES,
                LINES2,
            }
        }
    }

    struct
    _string {
        Rec[] s;

        struct 
        Rec {            
            ABSXY abs_move_pos;  // abs
            ID    c;
        }
    }

    struct
    _mix {
        Rec[] s;

        struct
        Rec {
            Type type;
            union {                
                _char   c;
                _string s;
            }

            enum Type {
                CHAR,
                STRING,
            }

            this (Type type, _char c) {
                this.type = type;
                this.c = c;
            }

            this (Type type, _string s) {
                this.type = type;
                this.s = s;
            }
        }
    }
}


enum Render_Flags : int {
    NO_RENDER_SIZE_ONLY = 0b0000_0001,
}


Size
draw_draws (R) (R range, SDL_Renderer* renderer, Pos pos, int flags=0) {
    alias E = ElementType!R;
    alias Contur = E.Contur;

    foreach (e; range) {        
        if (flags & Render_Flags.NO_RENDER_SIZE_ONLY) {
            return Size (e.w,e.h);
        }

        // 
        foreach (contur; e.s) {
            // move points
            auto points = contur.points.dup;
            foreach (ref p; points) {
                p.x += pos.x;
                p.y += pos.y;
            }

            final
            switch (contur.type) {
                case Contur.Type.POINTS: 
                    SDL_RenderDrawPoints (renderer,points.ptr,cast (int) points.length);
                    break;
                case Contur.Type.LINES: 
                    SDL_RenderDrawLines (renderer,points.ptr,cast (int) points.length);
                    break;
                case Contur.Type.LINES2: 
                    // ...
                    break;
            }
        }

        return Size (e.w,e.h);
    }

    return Size ();
}
