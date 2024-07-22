module ui.select_2;

import std.stdio : writeln;
import bindbc.sdl;
import types;
alias log = writeln;


struct
Select_2 {
    // 1
    // 2
    void
    draw (SDL_Renderer* renderer) {
        _draw_selection (renderer);
        _draw_1 (renderer);
        _draw_2 (renderer);
    }

    Size
    _draw_selection (SDL_Renderer* renderer) {
        int x,y,w,h;

        auto rect = SDL_Rect (x,y,w,h);
        // fill
        SDL_SetRenderDrawColor (renderer,0x22,0x22,0x88,0xFF);
        SDL_RenderFillRect (renderer,&rect);
        // border
        SDL_SetRenderDrawColor (renderer,0x22,0x22,0xFF,0xFF);
        SDL_RenderDrawRect (renderer,&rect);

        return Size (w,h);
    }

    Size
    _draw_1 (SDL_Renderer* renderer) {
        return Size ();
    }

    Size
    _draw_2 (SDL_Renderer* renderer) {
        return Size ();
    }
}

