module ui.select_2;

import std.stdio : writeln;
import bindbc.sdl;
import ui.render;
import ui.style;
import types;
//import gl_side : to_SDL_Rect;
alias log = writeln;


auto
Select_2 (E1,E2) (E1 e1, E2 e2, Pos pos, Size size, Pad pad=Pad()) {
    return _Select_2!(E1,E2) (e1,e2,pos,size,pad);
}

struct
_Select_2 (E1,E2) {
    E1   e1;
    E2   e2;
    Pos  pos;
    Size size;
    Pad  pad;

    int  selected; // 1 or 2

    // 1
    // 2
    Size
    draw (SDL_Renderer* renderer) {
        Size sz;
        sz = _draw_selection (renderer);
        sz = _draw_1 (renderer,pos,size);
        sz = _draw_2 (renderer,Pos (pos.x,pos.y+sz.h),size);

        return size;
    }

    Size
    _draw_selection (SDL_Renderer* renderer) {
        Pos  _pos  = _selection_pos ();
        Size _size = _selection_size ();

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
    _draw_1 (SDL_Renderer* renderer, Pos pos, Size size) {
        return
            Render (renderer,_e_pos (0))
                .render (e1);
    }

    Size
    _draw_2 (SDL_Renderer* renderer, Pos pos, Size size) {
        return
        Render (renderer,_e_pos (1))
                .render (e2);
    }

    Pos
    _e_pos (size_t i) {
        if (i == 0)
            return Pos (pad.l,pad.t);
        else
            return Pos (pad.l,pad.t + _selection_size.h);
    }

    Pos
    _selection_pos () {
        if (selected == 0)
            return Pos (0,0);
        else
            return Pos (0,_selection_size.h);
    }

    Size
    _selection_size () {
        return _e_size + pad;
    }

    Size
    _e_size () {
        return
            Render (null,Pos (),Render_Flags.NO_RENDER_SIZE_ONLY)
                .render (e1);
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
