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

    // load
    Load!E load;
    load.go (es);

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
    image_store.put (image); // 0
    image_store.put (image); // 1


    //
    auto gfx_backend = SDL_GFX_Backend!Frame ([]);
    gfx_backend.go (es,image_store);
}

struct
Frame {
    void
    draw (Image_store,G) (ref G g, ref ES es, ref Image_store image_store) {
        //g.draw_point (Pos (0,0), Color (0xFFFFFFFF));
        //g.draw_points ([Pos (0,0)], Color (0xFFFFFFFF));
        //g.draw_line (Pos (0,0), Pos (100,100), Color (0xFFFFFFFF));
        //g.draw_lines ([Pos (0,0), Pos (100,100)], Color (0xFFFFFFFF));

        // Control
        foreach (ref e; es)
            foreach (ref group; e.groups)
                group.go (group);

        // Draw
        foreach (ref e; es) {
            auto draw_id = e.draw_id;
            if (draw_id) {
                auto image = image_store.get (draw_id);
                auto moved_image = move_image (image, e.pos);
                g.draw_image (moved_image);
            }
        }
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


auto
move_image (ref Image image, Pos pos) {
    Image moved_image;
    foreach (ref rec; image.recs) {
        Pos[] poss;
        foreach (p; rec.pos)
            poss ~= Pos (p.x+pos.x, p.y+pos.y);
        moved_image.recs ~= Image_rec (rec.color,poss);
    }
    return moved_image;
}

struct 
Load (E) {
    void 
    go (ES)(ref ES es) {
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
        auto group_2 = cast (Group!E*) new Ryadki_group!E ();
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
