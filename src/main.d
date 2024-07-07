import std.range : lockstep, zip;
import std.stdio : writeln;
import bindbc.sdl;
import el;
import pos;
import color;
import image;
import font;
import group;
import glyph;
import walk_recursive : walk_recursive;
import draw : draw;
import background;
import button;
import store;
import sdl_gfx_backend;

alias log = writeln;

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
    auto gfx_backend = SDL_GFX_Backend!Glyph_frame ([]);
    gfx_backend.frame._init ();
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
Glyph_frame {
    Glyph glyph;

    void 
    _init () {
        glyph = Glyph ();
        glyph._lines._lines ~= G_line (Color(White),G_pos(0,100),G_pos(50,0));
        glyph._lines._lines ~= G_line (Color(White),G_pos(50,0),G_pos(100,100));
        glyph._lines._lines ~= G_line (Color(White),G_pos(25,75),G_pos(75,75));        
    }

    void
    draw (Draw_store,G) (ref G g, ref ES es, ref GS gs, ref Draw_store draw_store) {
        import draw_glyph;
        draw_glyph.draw (g,glyph);
    }

    void
    event (SDL_Event* e) {
        switch (e.type) {
            case SDL_MOUSEBUTTONDOWN: {
                import std.conv : to;
                import std.range : back;
                G_pos.X mx = e.button.x.to!(G_pos.X);
                G_pos.Y my = e.button.y.to!(G_pos.Y);
                auto last_pos = glyph._lines._lines.back.b;
                glyph._lines._lines ~= G_line (Color(White),last_pos,G_pos(mx,my));
                break;
            }
            default:
        }
    }
}


struct 
Load (E) {
    void 
    go (ES,GS)(ref ES es, ref GS gs) {
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
        gs ~= group_1;
        auto group_2 = cast (Group!E*) new Ryadki_group!E ();
        gs ~= group_2;
        //auto group_2 = groups.add!Ryadki_group ();
        foreach (ref e; es) {
            e.groups ~= group_1;
            e.groups ~= group_2;
        }

        // map
        auto datas = ["ПН","*","25/15","ВТ","*","25/15"];
        auto datag = group_1;
        Font font;
        foreach (ref e,d; lockstep (datag.es,datas)) {
            //e.draw_id = text_to_draw_id (d,font);
        }

        // A
        load_a ();

        //
        load_links ();
    }

    void
    load_a () {
        import draw_store;
        Draws draws;
        draws ~= _Draw (
            Color (0xFFFFFF), [
                // pos | angle
                // x,y | a,r
                // 255,255 | 255,255
                //
                // glyph -> contour-holes -> h_lines
                //                           GL_LINES
                //                           VK_PRIMITIVE_TOPOLOGY_LINE_LIST
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
    }

    void
    load_links () {
        import links;
        Links _links;

        Names_file names_file;
        names_file.read (); // auto-created from "links.txt", then cached to "names.txt"

        Links_file links_file;
        links_file.read ();
    }
}

Draw_id
text_to_draw_id (const ref string s, ref Font font) {
    Draw_id draw_id;

    // string to hash
    //   bytes sum
    //   if same 
    //     check each char

    return draw_id;
}

struct
String {
    const nothrow @trusted size_t getHash(in void* p);
}

void 
String_hash () {
    string a = "abc";
    auto hash1 = typeid(a).getHash(&a);
    auto stringHash = &(typeid(a).getHash);
    auto hash2 = stringHash(&a);
    assert(hash1 == hash2);
}

class 
FooString {
    int a, b;

    override size_t 
    toHash() { 
        return a + b; 
    }

    override bool 
    opEquals(Object o) {
        FooString foo = cast(FooString) o;
        return foo && a == foo.a && b == foo.b;
    }
}

struct 
MyString {
    import std.string;
    
    string str;

    size_t 
    toHash() const @safe pure nothrow {
        size_t hash;
        foreach (char c; str)
            hash = (hash * 9) + c;
        return hash;
    }

    bool 
    opEquals(ref const MyString s) const @safe pure nothrow {
        return std.string.cmp(this.str, s.str) == 0;
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

