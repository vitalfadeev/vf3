module ui.render;

import std.stdio : writeln;
import bindbc.sdl;
import ui.render;
import ui.style;
import font;
import types;
import cache : cache, Cache_id;
import gl_side : draw_draws;
alias log = writeln;


struct
Render {
       SDL_Renderer*    renderer;
       int              x,y;        // _cur_pos
       int              field_dx =  50;
       //Resources        resources;  // draws    = resources[id]
       //Font_cache!Draws font_cache;
       Style            style;
//    auto draws = font_cache.get_draws (font_pathname,font_size,'A');
//
//    pos,draws  // SDL_Point,(type,SDL_Point[])
//    SDL_RenderDrawLines (renderer,sdl_points.ptr,cast (int) sdl_points.length);

    //auto
    //cur_pos () {
    //    return _cur_pos;
    //}

    Size
    render_char (char c) { // resource_id
        // pos,char
        // current_style
        return 
            Font!(ftlib)
                .open (style.font_pathname)
                .open (style.font_size)
                .open (c)
                .read!E ()
                .cache (Cache_id (style.font_pathname,style.font_size,c))
                .draw_draws (renderer,x,y)  // Font_Glyph.ID.Iterator!(Font_Glyph.ID.E)
                ;
    }

    Size
    render_chars (char[] s) { // resource_id 
        // each char in chars:
        //   pos,char
        //   pos += step
        Size size;

        foreach (c; s) {
            SDL_SetRenderDrawColor (renderer,0xFF,0xFF,0xFF,0xFF);

            auto _size = 
                Font!(ftlib)
                .open (style.font_pathname)
                .open (style.font_size)
                .open (c)
                .read!E ()
                .cache (Cache_id (style.font_pathname,style.font_size,c))
                .draw_draws (renderer,x,y)  // Font_Glyph.ID.Iterator!(Font_Glyph.ID.E)
                ;

            x += _size.w;
            size.w += _size.w;
            size.h  = size.h < _size.h ? _size.h : size.h;

            //dx = 2;
            //dy = 0;
            //FT_Glyph_Metrics m = face.glyph.metrics;
            //// Size (m.width,m.height); 
            ////   n 26.6 pixel format (i.e., 1/64 of pixels),
            //step = Size (m.horiAdvance/64,m.vertAdvance/64);
            //pos += step;
        }

        return size;
    }

    Size
    render_int (int a) {
        import std.conv;
        auto s = a.to!string;
        return render_chars ((cast (char*) s.ptr)[0..s.length]);
    }

    Size
    render_field (T) (T a) { // resource_id
        // switch type
        //   case chars[]
        //     pos,chars
        //   case int
        //     to_chars
        //     pos,chars
        static if (is (T == char))
            return render_char (a);
        else
        static if (is (T == char[]))
            return render_chars (a);
        else
        static if (is (T == string))
            return render_chars (a.dup);
            //return render_chars (a.ptr[0..a.length]); 
            //return render_chars ((cast (char*) s.ptr)[0..s.length]);
        else
        static if (is (T == int))
            return render_int (a);
        else
        static if (
            is (T == byte) ||
            is (T == ubyte) ||
            is (T == short) ||
            is (T == ushort)
        )
            return render_int (cast (int) a);
        else
            return Size ();
    }

    Size
    render_struct_ptr (T) (T* a, int[] cols) { // resource_id
        return render_struct!T (a,cols);
    }

    Size
    render_struct (T) (T* a, int[] cols) { // resource_id
        // each field in fields
        //   pos,field
        Size   size;
        Size   sz;
        size_t i;
        int    col_x=x;

        if (cols is null)
            cols = [];
        if (cols.length == 0)
            cols.length = T.tupleof.length;

        static foreach (_var; T.tupleof) {
            //pragma (msg, ".", __traits(identifier,_var), ": ", typeof(_var));
            static if (is (typeof(_var) == string)) {
                x      = col_x;
                sz     = render_field (__traits (getMember,a,__traits(identifier,_var)));
                size.w = cols[i];
                size.h = size.h < sz.h ? sz.h : size.h;
                col_x += cols[i];
                i++;
            }
            else
            static if (is (typeof(_var) == char[255])) {
                import std.string : fromStringz;
                x      = col_x;
                sz     = render_field (__traits (getMember,a,__traits(identifier,_var)).fromStringz);
                size.w = cols[i];
                size.h = size.h < sz.h ? sz.h : size.h;
                col_x += cols[i];
                i++;
            }
            else
            static if (
                is (typeof(_var) == int) ||
                is (typeof(_var) == uint) ||
                is (typeof(_var) == byte) ||
                is (typeof(_var) == ubyte) ||
                is (typeof(_var) == short) ||
                is (typeof(_var) == ushort)
            ) {
                x      = col_x;
                sz     = render_field (__traits (getMember,a,__traits(identifier,_var)));
                size.w = cols[i];
                size.h = size.h < sz.h ? sz.h : size.h;
                col_x += cols[i];
                i++;
            }
        }

        return size;
    }

    Size
    render_selection (int x, int y, int w, int h) { // resource_id
        auto rect = SDL_Rect (x,y,w,h);
        SDL_SetRenderDrawColor (renderer,0x22,0x22,0x88,0xFF);
        SDL_RenderFillRect (renderer,&rect);
        SDL_SetRenderDrawColor (renderer,0x22,0x22,0xFF,0xFF);
        SDL_RenderDrawRect (renderer,&rect);
        return Size (w,h);
    }

    Size
    render (T) (T a, int[] cols=null) {
        import std.traits : isPointer,PointerTarget;
        static if (isPointer!T && (is (PointerTarget!T == struct)))
            return render_struct (a,cols);
        else
        static if (is (T == struct))
            render_struct (&a,cols);
        else
            return render_field (a);
    }


    //
    struct
    E {
        Type    type;
        Point[] points;  // rel
        int     w;
        int     h;

        enum Type {
            POINTS,
            LINES,
            LINES2,
        }

        alias Point = SDL_Point;
    }
}

