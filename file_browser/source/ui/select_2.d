module ui.select_2;

import std.stdio : writeln;
import bindbc.sdl;
import ui.render;
import ui.style;
import ui.pad;
import types;
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

    // 1
    // 2
    Size
    draw (SDL_Renderer* renderer) {
        Size sz;
        sz = _draw_selection (renderer);
        sz = _draw_1 (renderer,pos,size);
        sz = _draw_2 (renderer,Pos(pos.x,pos.y+sz.h),size);

        return size;
    }

    Size
    _draw_selection (SDL_Renderer* renderer) {
        auto size = Size (size.w,87);
        auto rect = to_SDL_Rect (pos,size);
        // fill
        SDL_SetRenderDrawColor (renderer,0x22,0x22,0x88,0xFF);
        SDL_RenderFillRect (renderer,&rect);
        // border
        SDL_SetRenderDrawColor (renderer,0x22,0x22,0xFF,0xFF);
        SDL_RenderDrawRect (renderer,&rect);

        return Size ();
    }

    Size
    _draw_1 (SDL_Renderer* renderer, Pos pos, Size size) {
        return
            Render (renderer, pos.x+pad.l, pos.y+pad.t)
                .render (e1);
    }

    Size
    _draw_2 (SDL_Renderer* renderer, Pos pos, Size size) {
        return
            Render (renderer, pos.x+pad.l, pos.y+pad.t)
                .render (e2);
    }
}

SDL_Rect
to_SDL_Rect (Pos pos, Size size) {
    return SDL_Rect (pos.x,pos.y,size.w,size.h);
}