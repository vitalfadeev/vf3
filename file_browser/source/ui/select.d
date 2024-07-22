module ui.select;

import std.stdio : writeln;
import std.range : ElementType;
import bindbc.sdl;
import ui.render;
import ui.style;
import types;
import std.algorithm.searching : find;
import std.algorithm.searching : countUntil;
alias log = writeln;


auto
Select (R) (R range, Pos pos, Size size, Pad pad=Pad()) {
    return _Select!(R) (range,pos,size,pad);
}

struct
_Select (R) {
    R    range;  // [0..length]
    Pos  pos;
    Size size;
    Pad  pad;

    size_t selected; // 1 or 2
    int[]  cols = [50,50,50,50,150,50,50];

    E[]    frame; // = range [start..end]

    alias E = ElementType!R;

    // 1
    // 2
    Size
    draw (SDL_Renderer* renderer) {
        Size   sz;
        size_t i;

        if (frame.length == 0 && range.length != 0)
            frame = range[];

        foreach (e; frame) {
            if (_e_pos (i,e).y > size.h)
                break;

            if (selected == i)
                sz = _draw_selection (renderer,i,e);

            sz = _draw_e (renderer, i, e, Pos (pos.x,pos.y+sz.h), size);

            i++;
        }

        frame.length = i;

        //
        _draw_scrollbar (renderer);

        return size;
    }

    Size
    _draw_selection (SDL_Renderer* renderer, size_t i, E e) {
        Pos  _pos  = _selection_pos (i,e);
        Size _size = _selection_size (i,e);

        //
        auto rect = to_SDL_Rect (_pos,Size (size.w,_size.h));

        // fill
        SDL_SetRenderDrawColor (renderer,0x22,0x22,0x88,0xFF);
        SDL_RenderFillRect (renderer,&rect);

        // border
        SDL_SetRenderDrawColor (renderer,0x22,0x22,0xFF,0xFF);
        SDL_RenderDrawRect (renderer,&rect);

        // content
        auto _ep = _e_pos (i,e);
        auto _es = _e_size (i,e);
        auto _cr = to_SDL_Rect (_ep,_es);
        SDL_SetRenderDrawColor (renderer,0x22,0x22,0xFF,0xFF);
        SDL_RenderDrawRect (renderer,&_cr);

        return _size;
    }

    Size
    _draw_e (SDL_Renderer* renderer, size_t i, E e, Pos pos, Size size) {
        return
            Render (renderer,_e_pos (i,e))
                .render (e,cols);
    }

    void
    _draw_scrollbar (SDL_Renderer* renderer) {
        //
    }

    Pos
    _e_pos (size_t i, E e) {
        if (i == 0)
            return Pos (pad.l,pad.t);
        else
            return Pos (pad.l,pad.t + _selection_size (i,e).h * cast (int) i);
    }

    Size
    _e_size (size_t i, E e) {
        return
            Render (null,Pos (),Render_Flags.NO_RENDER_SIZE_ONLY)
                .render (e,cols);
    }

    Pos
    _selection_pos (size_t i, E e) {
        if (selected == 0)
            return Pos (0,0);
        else
            return Pos (0,_selection_size (i,e).h * cast (int) i);
    }

    Size
    _selection_size (size_t i, E e) {
        return _e_size (i,e) + pad;
    }

    void
    event (SDL_Event* e) {
        switch (e.type) {
            case SDL_KEYDOWN:
                on_key (&e.key);
                break;
            default:
        }
    }

    void
    on_key (SDL_KeyboardEvent* e) {
        switch (e.keysym.scancode) {
            case SDL_SCANCODE_DOWN   : _on_key_down (e); break;
            case SDL_SCANCODE_UP     : _on_key_up (e);  break;
            case SDL_SCANCODE_RETURN : _on_key_return (e);  break;
            default:
        }
    }

    void
    _on_key_down (SDL_KeyboardEvent* e) {
        if (selected == frame.length-1) {
            if (frame[$-1] != range[$-1]) {
                auto i = range.countUntil (frame[0]);
                if (i != -1) {
                    if (i == 0)
                        frame = range[1..$];
                    else
                        frame = range[i+1..$];
                }
                else {
                    frame = range[];
                }
            }
            else {
                //frame = range[];
                //selected = 0;
            }
        }
        else
            selected++;
    }

    void
    _on_key_up (SDL_KeyboardEvent* e) {
        if (selected == 0) {
            if (frame[0] == range[0]) {
                //
            }
            else {
                auto i = range.countUntil (frame[0]);
                if (i != -1) {
                    if (i == 0)
                        frame = range[0..$];
                    else
                        frame = range[i-1..$];
                }
                else {
                    frame = range[];
                }
            }
        }
        else
            selected--;
    }

    void
    _on_key_return (SDL_KeyboardEvent* e) {
        import std.string : fromStringz;
        log (selected, ": ", frame[selected].d_name.fromStringz);
    }
}

SDL_Rect
to_SDL_Rect (Pos pos, Size size) {
    return SDL_Rect (pos.x,pos.y,size.w,size.h);
}
