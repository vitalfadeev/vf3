import el;
import pos;
import color;
import image;
import group;
import walk_recursive : walk_recursive;
import draw : draw;
import std.stdio : writeln;
import background;
import button;
import store;
import sdl_gfx_backend;

void 
main () {
    ES es;
    GS gs;

    // load
    Load!E load;
    load.go (es,gs);

    // place

    // draw

    // Image_store
    // image: {color,lines}, {color,lines},...
    Image image;
    image.recs ~= Image_rec (
        Color (0xFFFFFF), [
            Pos (0,0), 
            Pos (100,0), 
            Pos (100,100), 
            Pos (0,100), 
            Pos (0,0)
        ]);
    alias Image_store = Store!Image;
    Image_store image_store;
    image_store.s.length = 2;
    image_store.put (0, image); // 0
    image_store.put (1, image); // 1

    import draw_store;
    Draws draws;
    draws ~= _Draw (
        Color (0xFFFFFF), [
            Pos (0,0), 
            Pos (100,0), 
            Pos (100,100), 
            Pos (0,100), 
            Pos (0,0)
        ]);
    alias Draw_store = Store!Draws;
    Draw_store _draw_store;
    _draw_store.s.length = 2;
    _draw_store.put (0, draws); // 0
    _draw_store.put (1, draws); // 1


    //
    auto gfx_backend = SDL_GFX_Backend!Frame ([]);
    gfx_backend.go (es,gs,_draw_store);
}

struct
Frame {
    void
    draw (Draw_store,G) (ref G g, ref ES es, ref GS gs, ref Draw_store draw_store) {
        //g.draw_point (Pos (0,0), Color (0xFFFFFFFF));
        //g.draw_points ([Pos (0,0)], Color (0xFFFFFFFF));
        //g.draw_line (Pos (0,0), Pos (100,100), Color (0xFFFFFFFF));
        //g.draw_lines ([Pos (0,0), Pos (100,100)], Color (0xFFFFFFFF));

        // Control
        foreach (ref group; gs)
            group.go (group);

        // Draw
        foreach (ref e; es)
            if (e.draw_id)
                g.draw_id (e.draw_id, e.pos, draw_store);
    }

    //void
    //event (SDL_Event* e) {
    //    switch (e.type) {
    //        case SDL_MOUSEBUTTONDOWN:
    //            // ...
    //            break;
    //        default:
    //    }
    //}
}


struct 
Load (E) {
    void 
    go (ES,GS)(ref ES es, ref GS groups) {
        // text,icon,text
        // text,icon,text
        //
        // ryad 1
        es ~= cast (E*) new Text!E ();
        es ~= cast (E*) new Icon!E ();
        es ~= cast (E*) new Text!E ();
        // ryad 2
        es ~= cast (E*) new Text!E ();
        es ~= cast (E*) new Icon!E ();
        es ~= cast (E*) new Text!E ();

        // set images
        foreach (ref e; es) 
            e.draw_id = cast (ubyte) 1;

        // set groups
        auto group_1 = new Group!E ();
        groups ~= group_1;
        auto group_2 = cast (Group!E*) new Ryadki_group!E ();
        groups ~= group_2;
        //auto group_2 = groups.add!Ryadki_group ();
        foreach (ref e; es) {
            e.groups ~= group_1;
            e.groups ~= group_2;
        }
    }
}

// data
// 1   2  3
// --  -  -----
// ПН  *  25/15 
// ВТ  *  25/15 
//
// draw_id
// ПН    = 1
// ВТ    = 2
// *     = 3
// 25/15 = 4
//
// text_to_draw_id (text,font)
//   hash (text,font)
//   check draw_store
//     put hash,draws
//     get draw_id
//   return draw_id
//
// foreach (s; ["ПН","*","25/15","ВТ","*","25/15"])
//   e.draw_id = text_to_draw_id (s,font)
//
// foreach (pair; (pairs (es,datas))
//   e = pair[0]
//   s = pair[1]
//   e.draw_id = text_to_draw_id (s,font)
