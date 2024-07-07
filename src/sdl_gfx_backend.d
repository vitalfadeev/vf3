version (SDL):

import std.conv;
import std.format;
import std.stdio;
import bindbc.sdl;
import pos;
import color;
import image;
import el : Draw_id;
import draw_store : Draws;

struct
SDL_GFX_Backend (Frame) {
    void
    draw_point (Pos pos, Color color) {
        SDL_SetRenderDrawColor (renderer, color.r, color.g, color.b, color.a);
        SDL_RenderDrawPoint (renderer, pos.x, pos.y);
    }

    void
    draw_points (Pos[] poss, Color color) {
        SDL_SetRenderDrawColor (renderer, color.r, color.g, color.b, color.a);
        SDL_Point[] sdl_points;
        foreach (p; poss)
            sdl_points ~= SDL_Point (p.x,p.y);
        SDL_RenderDrawPoints (renderer, sdl_points.ptr, cast (int) sdl_points.length);
    }

    void
    draw_line (Pos pos, Pos pos2, Color color) {
        SDL_SetRenderDrawColor (renderer, color.r, color.g, color.b, color.a);
        SDL_RenderDrawLine (renderer, pos.x, pos.y, pos2.x, pos2.y);
    }

    void
    draw_line (G_pos a, G_pos b, Color color) {
        SDL_SetRenderDrawColor (renderer, color.r, color.g, color.b, color.a);
        SDL_RenderDrawLine (renderer, a.x, a.y, b.x, b.y);  // draws the line to include both end points.
    }

    void
    draw_lines (Pos[] poss, Color color) {
        SDL_SetRenderDrawColor (renderer, color.r, color.g, color.b, color.a);
        SDL_Point[] sdl_points;
        foreach (p; poss)
            sdl_points ~= SDL_Point (p.x,p.y);
        SDL_RenderDrawLines (renderer, sdl_points.ptr, cast (int) sdl_points.length);
    }

    void
    draw_image (ref Image image) {
        foreach (image_rec; image.recs) {
            SDL_SetRenderDrawColor (
                renderer, 
                image_rec.color.r, 
                image_rec.color.g, 
                image_rec.color.b, 
                image_rec.color.a);

            SDL_Point[] sdl_points;
            foreach (p; image_rec.pos)
                sdl_points ~= SDL_Point (p.x,p.y);

            SDL_RenderDrawLines (renderer, sdl_points.ptr, cast (int) sdl_points.length);
        }
    }

    void
    draw_draws (ref Draws draws) {
        foreach (d; draws) {
            SDL_SetRenderDrawColor (
                renderer, 
                d.color.r, 
                d.color.g, 
                d.color.b, 
                d.color.a);

            SDL_Point[] sdl_points;
            foreach (p; d.pos)
                sdl_points ~= SDL_Point (p.x,p.y);

            SDL_RenderDrawLines (renderer, sdl_points.ptr, cast (int) sdl_points.length);
        }
    }

    void
    draw_id (Draw_store) (Draw_id draw_id, Pos pos, ref Draw_store draw_store) {
        auto draws = draw_store.get (draw_id);
        auto moved = transform_move (draws, pos);
        draw_draws (moved);
    }

    auto
    transform_move (ref Draws draws, Pos pos) {
        Draws copy;
        copy = draws.copy (copy);

        foreach (ref d; copy)
            foreach (ref p; d.pos)
                p = Pos (p.x+pos.x, p.y+pos.y);

        return copy;
    }


    void
    draw (Glyph) (ref Glyph glyph) {
        import draw_glyph;
        draw_glyph (glyph,this);
    }


    //
    SDL_Window*   window;
    SDL_Renderer* renderer;
    Frame         frame;

    this (string[] args) {
        init_sdl ();
    }

    void 
    go (ES,GS,Draw_store) (ref ES es, ref GS gs, ref Draw_store draw_store) {
        new_window (window);
        new_renderer (window, renderer);
        event_loop (window, renderer, frame, es, gs, draw_store);
    }

    void 
    init_sdl () {
        SDLSupport ret = loadSDL();

        if (ret != sdlSupport) {
            if (ret == SDLSupport.noLibrary) 
                throw new Exception ("The SDL shared library failed to load");
            else 
            if (ret == SDLSupport.badLibrary) 
                throw new Exception ("One or more symbols failed to load. The likely cause is that the shared library is for a lower version than bindbc-sdl was configured to load (via SDL_204, GLFW_2010 etc.)");
        }

        loadSDL ("sdl2.dll");
    }

    //
    void 
    new_window (ref SDL_Window* window) {
        // Window
        window = 
            SDL_CreateWindow (
                "SDL2 Window",
                SDL_WINDOWPOS_CENTERED,
                SDL_WINDOWPOS_CENTERED,
                640, 480,
                0
            );

        if (!window)
            throw new SDLException ("Failed to create window");

        // Update
        SDL_UpdateWindowSurface (window);
    }


    //
    void 
    new_renderer (SDL_Window* window, ref SDL_Renderer* renderer) {
        renderer = SDL_CreateRenderer (window, -1, SDL_RENDERER_SOFTWARE);
    }


    //
    void 
    event_loop (ES,GS,Draw_store) (ref SDL_Window* window, SDL_Renderer* renderer, ref Frame frame, ref ES es, ref GS gs, ref Draw_store draw_store) {
        bool _go = true;

        while (_go) {
            SDL_Event e;

            while (SDL_PollEvent (&e) > 0) {
                // Process Event
                // Process Event
                switch (e.type) {
                    case SDL_QUIT:
                        _go = false;
                        break;
                    case SDL_MOUSEBUTTONDOWN: 
                        static if (__traits(hasMember, frame, "event"))
                            frame.event (&e);
                        break;
                    default:
                }

                // Draw
                frame.draw (this, es, gs, draw_store);

                // Rasterize
                SDL_RenderPresent (renderer);
            }

            // Delay
            SDL_Delay (100);
        }        
    }


    //
    class 
    SDLException : Exception {
        this (string msg) {
            super (format!"%s: %s" (SDL_GetError().to!string, msg));
        }
    }


        ////
        //struct
        //Frame {
        //    void
        //    draw (SDL_Renderer* renderer) {
        //        SDL_SetRenderDrawColor (renderer, 0, 0, 0, 0);
        //        SDL_RenderClear (renderer);
        //        SDL_SetRenderDrawColor (renderer, 0xFF, 0xFF, 0xFF, 0xFF);
        //        // SDL_RenderDrawPoint(renderer, x, y);
        //        SDL_RenderDrawLine (renderer,0,0,100,100);
        //        // SDL_RenderDrawRect (renderer,&rect);
        //        // ...
        //    }

        //    void
        //    event (SDL_Event* e) {
        //        switch (e.type) {
        //            case SDL_MOUSEBUTTONDOWN:
        //                // ...
        //                break;
        //            default:
        //        }
        //    }
        //}
}

alias Draw_na = SDL_GFX_Backend;
