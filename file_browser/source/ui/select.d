module ui.select;

import std.stdio : writeln;
import std.range : ElementType;
import bindbc.sdl;
import ui.render;
import ui.style;
import types;
import gl_side;
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
    Mouse_Sensable mouse_sensable;
    Pos_Size mouse_hover;

    alias E = ElementType!R;

    // 1
    // 2
    Draw_Return
    draw (SDL_Renderer* renderer) {
        Size   sz;
        size_t i;
        
        mouse_sensable.pss.length = 0;
        mouse_sensable.dgs.length = 0;

        if (frame.length == 0 && range.length != 0)
            frame = range[];

        foreach (e; frame) {
            auto epos = _e_pos (i,e);

            if (epos.y > size.h)
                break;

            Pos  sel_pos  = _selection_pos (i,e);
            Size sel_size = _selection_size (i,e);

            if (selected == i)
                sz = _draw_selection (renderer,i,e);

            if (mouse_hover.pos == sel_pos)
                _draw_mouse_sensable (renderer,i,e);

            sz = _draw_e (renderer,i,e,epos,size);

            // mouse sensable
            mouse_sensable.pss ~= Pos_Size (sel_pos,sel_size);
            mouse_sensable.dgs ~= &on_mouse_sensable;

            i++;
        }

        frame.length = i;

        //
        _draw_scrollbar (renderer);

        return
            Draw_Return (
                Pos_Size (pos,size),
                mouse_sensable
            );
    }

    Size
    _draw_selection (SDL_Renderer* renderer, size_t i, E e) {
        Pos  _pos  = _selection_pos (i,e);
        Size _size = _selection_size (i,e);

        //
        auto rect = to_SDL_Rect (_pos,_size);

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

    void
    _draw_mouse_sensable (SDL_Renderer* renderer, size_t i, E e) {
        auto rect = mouse_hover.to_SDL_Rect ();

        // fill
        SDL_SetRenderDrawColor (renderer,0x44,0x44,0xAA,0xFF);
        SDL_RenderFillRect (renderer,&rect);

        // border
        SDL_SetRenderDrawColor (renderer,0x44,0x44,0xFF,0xFF);
        SDL_RenderDrawRect (renderer,&rect);
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
        if (i == 0)
            return Pos (0,0);
        else
            return Pos (0,_selection_size (i,e).h * cast (int) i);
    }

    Size
    _selection_size (size_t i, E e) {
        return 
            Size (
                size.w, 
                (_e_size (i,e) + pad).h
            );
        //return _e_size (i,e) + pad;
    }

    void
    event (SDL_Event* e) {
        switch (e.type) {
            case SDL_KEYDOWN:
                on_key (&e.key);
                break;
            case SDL_MOUSEMOTION:
                on_mouse_motion (&e.motion);
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
    on_mouse_motion (SDL_MouseMotionEvent* e) {
        // find mous_sensable
        //   colorize
        //   redraw
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

    void
    on_mouse_sensable (Pos_Size pos_size, Pos pos) {
        // colorize
        // redraw
        mouse_hover = pos_size;
    }
}

