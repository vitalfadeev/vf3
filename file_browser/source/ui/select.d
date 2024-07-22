module ui.select;

import std.stdio : writeln;
import std.range : ElementType;
import bindbc.sdl;
import ui.render;
import ui.style;
import types;
alias log = writeln;


auto
Select (R) (R range, Pos pos, Size size, Pad pad=Pad()) {
    return _Select!(R) (range,pos,size,pad);
}

struct
_Select (R) {
    R    range;
    Pos  pos;
    Size size;
    Pad  pad;

    int  selected; // 1 or 2

    alias E = ElementType!R;

    // 1
    // 2
    Size
    draw (SDL_Renderer* renderer) {
        Size   sz;
        size_t i;

        foreach (e; range) {
            if (selected == i)
                sz = _draw_selection (renderer,e);

            sz = _draw_e (renderer, i, e, Pos (pos.x,pos.y+sz.h), size);

            i++;
        }

        return size;
    }

    Size
    _draw_selection (SDL_Renderer* renderer, E e) {
        Pos  _pos  = _selection_pos (e);
        Size _size = _selection_size (e);

        //
        auto rect = to_SDL_Rect (_pos,Size (size.w,_size.h));

        // fill
        SDL_SetRenderDrawColor (renderer,0x22,0x22,0x88,0xFF);
        SDL_RenderFillRect (renderer,&rect);

        // border
        SDL_SetRenderDrawColor (renderer,0x22,0x22,0xFF,0xFF);
        SDL_RenderDrawRect (renderer,&rect);

        return _size;
    }

    Size
    _draw_e (SDL_Renderer* renderer, size_t i, E e, Pos pos, Size size) {
        return
            Render (renderer,_e_pos (i,e))
                .render (e);
    }

    Pos
    _e_pos (size_t i, E e) {
        if (i == 0)
            return Pos (pad.l,pad.t);
        else
            return Pos (pad.l,pad.t + _selection_size (e).h);
    }

    Pos
    _selection_pos (E e) {
        if (selected == 0)
            return Pos (0,0);
        else
            return Pos (0,_selection_size (e).h);
    }

    Size
    _selection_size (E e) {
        return _e_size (e) + pad;
    }

    Size
    _e_size (E e) {
        return
            Render (null,Pos (),Render_Flags.NO_RENDER_SIZE_ONLY)
                .render (e);
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
            case SDL_SCANCODE_DOWN : _on_key_down (e); break;
            case SDL_SCANCODE_UP   : _on_key_up (e);  break;
            default:
        }
    }

    void
    _on_key_down (SDL_KeyboardEvent* e) {
        if (selected == 1)
            selected = 0;
        else
            selected++;
    }

    void
    _on_key_up (SDL_KeyboardEvent* e) {
        if (selected == 0)
            selected = 1;
        else
            selected--;
    }
}

SDL_Rect
to_SDL_Rect (Pos pos, Size size) {
    return SDL_Rect (pos.x,pos.y,size.w,size.h);
}