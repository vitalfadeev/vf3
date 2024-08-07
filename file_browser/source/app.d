import std.conv;
import std.format;
import std.stdio;
import bindbc.loader;
import bindbc.freetype;
import bindbc.sdl;
import gl_side;
import font_cache;
import font;
import types;
import ui.style;
import ui.render;
import ui.select_2;
import ui.select;
import file : Dir;
import slice;
alias log = writeln;

version = Android_or_linux;

// -lGLESv2

// https://docs.tizen.org/application/native/guides/graphics/sdl-opengles/

// » clang++  \
//   --std=c++14 -Wreturn-type -g -O0  \
//   -D_GLIBCXX_DEBUG -DCXXPOOL_ENABLE_THREAD_AFFINITIES  \
//   `sdl2-config  --cflags --libs`  \
//   -lGLESv2 -lEGL  \
//   -lpthread -lstdc++fs  \
//   ./hello_triangle.cpp  \
//   -o hello_triangle


void 
main() {
    // load FreeType
    load_FT ();

    // Init FreeType
    init_ft ();

    //
	//auto grid = Dir_Grid ();
	//grid.load ();
	//grid.create_cols ();

	// Init
	init_sdl ();

	// Window, Surface
	SDL_Window*  window;
	new_window (window);

    // OpenGL context
    SDL_GLContext glc;
    new_gl_context (window,glc);

    //
    init_gl (window,glc);

	// Renderer
	SDL_Renderer* renderer;
	new_renderer (window, renderer);

    //
    Font font;  // FreeType font loader

	// Event Loop
	auto frame = 
        Frame (
            GL_Side (
                renderer,
                window,
                GL_View (GL_View.Appdata (null,null,null,window)),
                &font.load_from_slow_mem_cb  // load char with FreeType
            )
        );
	event_loop (window,renderer,frame);

    //
    //FT_Done_FreeType (lib);
}

// R Range
// struct[]

// vid
//   grid
//     1 2 3 4 5 6 7
//
//   list
//     icon text
//     icon text
//     icon text
//
/+
struct
Grid (R,E) {
    R r;

    void
    go () {
    	string for_draw;

        foreach (e; r) {
            for_draw = template (e);
        }

        //
        draw (for_draw);
    }

    string
    template (E e) {
        // fmt(1) fmt(2) \n
        string s;

        static foreach (i,F;fields!E) {
        	s ~= fmt (1);  // icon id
        	s ~= fmt (2);  // name .ext
        	s ~= "\n";
    	}
        return s;
    }

    void
    format (E e) {
    	//
    }

    void
    draw (G g, string for_draw) {
        //
    }

    struct
    G {
    	Points[resource_id] points;  // GL points[a]

        void
        go () {
            //
        }
    }

    void
    columns () {
        //
    }

    struct
    Columns {
        // Element
        //   font
        //     family
        //     size
        //   text
        // 
        // Rich_text
        //   Icon
        //   Text
        //     font
        //
        // Icon
        //   resource_id  // icons[resource_id]
        // Text
        //   resource_id  // chars[resource_id]
        //                // font.glyphs[resource_id]
        // 
        // draw_char [resource_id]
        // draws     [resource_id]
        //
        // Unicode
        //   page - for text
        //   page - for icons
        //
        // All resource_id  -> copy to clipboard with (font,size,icons,"draws")
        //
        // Select_mode
        //   Line_selection
        //   Char_selection
        //
        // Box
        // Box for content
        //   width  -> Line_selection
        //
        // resource_id -> conturs -> h_lines
        // chars                     draws
        //
        // resource_id -> conturs -> points
        // chars                     
        //
        // icon_1 file_name_1.ext\n
        // icon_1 file_name_2.ext\n
        //
        // data
        //   icon_1 file_name_1.ext
        //   icon_1 file_name_2.ext
        //  +
        // template
        //   (w:50):$1 (w:200 .cond() ):$2\n
        //   fmt_1  $1 fmt_2            $2\n
        //   fmt(1)  fmt(2)               \n
        //  =
        // (w:50):icon_1 (w:200       ):file_name_1.ext\n
        // (w:50):icon_1 (w:200,font:b):file_name_2.ext\n
        // \w 50 icon_1 \w 200 \f b file_name_2.ext\n
        //
        // render
        //   case '\': special case
        //     case 'w': width
        //     case 'f': font
        //     case '\': \
        //   default:  resource_id
    }

    void
    auto_columns () {
        static foreach (type,name; types_fields!E) {
        	//
        }
    }
}

template 
types_fields (T) {
	alias types_fields = void;
}

// Box         - sensable
// id1,id2,id3 - sensable
//
// Box         - ut-sensable
// id1,id2,id3 -    sensable
//
// Clip_box
// \c 200 123 - clip box width 200
//
// Sensable_box
// icon_1 file_name_1.ext - Sensable_box [icon_1 file_name_1.ext]
// icon_1 file_name_2.ext
//
// Sensable_box - linked to struct {icon file_name}
// 
// resource_id[]
// Sensable_box[] - on any group of data
//
// Resource_group
//   resource_id[]
//
// Resource_group - can be like a resource/. can has resource_id

// char  resource <- |
// icon  resource <- |
// group resource ---|
struct
Resource {
    alias ID = short;  // 0..65535
    ID id;

    private static ID _new_id;

    static
    ID
    new_id () {
        _new_id++;
        return _new_id;
    }
}

struct
Char_resource {
	Resource _super;
	alias _super this;

    void
    _new () {
        auto _new_id = Resource.new_id ();
    }
}

struct
Icon_resource {
    Resource _super;
    alias _super this;
}

struct
Group_resource {
	Resource _super;
	alias _super this;
}

struct
Resources {
	Resource[] s;
}

// Sensable
// Keyboard_Sensable
// Mouse_Sensable
//
// Vid - Sensable - Input
//
// Data + Template -> Screen (Sensable)
//                 -> Sensable
struct
Template (Data) {
    void
    go (Data data) {
    	g.draw ();
        return tuple!(Draws (), Sensable (data.id));
    }
}

struct
Sensable {
    bool
    sense (Pos pos) {
    	return false;
    }
}

struct
Data {
    ID id;  // data_id
}

auto
Grid_Template (Data) {
	G.Draws ();

	return 
		Ret (
			G.Draws[], Mouse_Sensable[], Keyboard_Sensable[]
		);  // points
}


void _new_Grid () {
	// ext4_dir_entry_2
	//   inode
	//   rec_len
	//   name_len
	//   name[EXT4_NAME_LEN]
	// 
	// 0x0 Unknown.
	// 0x1 Regular file.
	// 0x2 Directory.
	// 0x3 Character device file.
	// 0x4 Block device file.
	// 0x5 FIFO.
	// 0x6 Socket.
	// 0x7 Symbolic link.	
	//
	// ext4_extended_dir_entry_2
	//
	// inode
	// dentry
	// 
	// filp_open ()
	// iterate_dir ()
	// dir_context  // include/linux/fs.h
}


//
// #include <dirent.h>
// APPLICATION USAGE
// The readdir() function should be used in conjunction with opendir(), closedir(), and rewinddir() to examine the contents of the directory.
// The readdir_r() function is thread-safe and shall return values in a user-supplied buffer instead of possibly using a static data area that may be overwritten by each call.

+/

//
void
load_FT () {
    /*
    This code attempts to load the FreeType shared library using
    well-known variations of the library name for the host system.
    */
    auto ret = loadFreeType ();
    if (ret != ftSupport) {
        import bindbc.loader;
        import core.stdc.stdio: printf;
        foreach (error; errors){
                printf ("%s: %s\n", error.error, error.message);
        }
        return;
    }

    // static lib bindings
    //FT_Library lib;
    //FT_Init_FreeType (&lib);    
}

void
init_ft () {
    FT_Error err;
    err = FT_Init_FreeType (&ftlib);
    if (err) {
        printf ("Loading error: %s", FT_Error_String (err));
    }

    int maj, min, pat;
    FT_Library_Version (ftlib, &maj, &min, &pat);
    assert (maj >= 2);
    assert (min >= 13);
}

struct 
FT_Point {
    FT_Pos x;
    FT_Pos y;
}

struct
Point {
    FT_Point _super;
    alias _super this;
}


// text + font (face,size)
// char[] + font (face,size)
// font (face,size)
//   chars
//   glyphs
//   draws


//
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

    //loadSDL ("sdl2.dll");
}


//
void 
new_window (ref SDL_Window* window) {
    // Window
    window = 
        SDL_CreateWindow (
            __FILE_FULL_PATH__, // "SDL2 Window",
            SDL_WINDOWPOS_CENTERED,
            SDL_WINDOWPOS_CENTERED,
            640, 480, //1366, 768
            SDL_WINDOW_SHOWN | SDL_WINDOW_OPENGL
        );

    if (!window)
        throw new SDLException ("Failed to create window");

    // Update
    SDL_UpdateWindowSurface (window);
}



auto
new_gl_context (SDL_Window* window, ref SDL_GLContext glc) {
    // Create context for OpenGL window
    glc = SDL_GL_CreateContext (window);
    if (glc is null) {
        throw new SDLException ("[SDL] GL context creation failed!");
        return -1;
    }

    // Set context as current
    auto err = SDL_GL_MakeCurrent (window,glc);
    if (err) 
        throw new SDLException ("SDL_GL_MakeCurrent: ");

    //
    if (SDL_GL_SetSwapInterval (1) < 0) {
        log ("Warning: Unable to set VSync! SDL Error: %s",SDL_GetError ());
    }

    //
    //GLint GLMajorVer, GLMinorVer;
    //glGetIntegerv (GL_MAJOR_VERSION,&GLMajorVer);
    //glGetIntegerv (GL_MINOR_VERSION,&GLMinorVer);
    int GLMajorVer, GLMinorVer;
    SDL_GL_GetAttribute (SDL_GL_CONTEXT_MAJOR_VERSION,&GLMajorVer);
    SDL_GL_GetAttribute (SDL_GL_CONTEXT_MINOR_VERSION,&GLMinorVer);
    log ("OpenGL version: ",GLMajorVer,".",GLMinorVer);

    return 0;
}


//
void 
new_renderer (SDL_Window* window, ref SDL_Renderer* renderer) {
version (GL_ES_2)
    renderer = 
        SDL_CreateRenderer (
            window, 
            -1, 
            SDL_RENDERER_ACCELERATED | SDL_RENDERER_TARGETTEXTURE
        );
else 
    renderer = 
        SDL_CreateRenderer (
            window, 
            -1, 
            SDL_RENDERER_SOFTWARE
        );
}

//
void 
event_loop (ref SDL_Window* window, SDL_Renderer* renderer, ref Frame frame) {
    bool _go = true;

    while (_go) {
        SDL_Event e;

        while (SDL_WaitEvent (&e) > 0) {
            // Process Event
            // Process Event
            switch (e.type) {
                case SDL_QUIT:
                    _go = false;
                    return;
                    break;
                case SDL_MOUSEBUTTONDOWN:
                    frame.event (&e);
                    return;
                    break;
                case SDL_KEYDOWN:
                    frame.event (&e);
                    break;
                case SDL_MOUSEMOTION:
                    frame.event (&e);
                    break;
                default:
            }

            // Draw
            frame.draw (renderer,window);

            // Rasterize
            //SDL_RenderPresent (renderer);
        }

        // Delay
        //SDL_Delay (100);
    }        
}


//
class 
SDLException : Exception {
    this (string msg) {
        super (format!"%s: %s" (SDL_GetError().to!string, msg));
    }
}


//
struct
Frame {
    GL_Side             gl_side;
    //Font_cache!Draws    font_cache;
    //Fonts!Draws.Font_id font_id;

    //this (bool _) {
    //    font_id = font_cache.fonts.add (font_pathname);
    //}


    struct 
    E1 {
        string abc = "ABC";
    }
    struct 
    E2 {
        string def = "DEF";
    }
    struct 
    E {
        string f1 = "abc";
        string f2 = "123";
        int    f3 = 4;
    }

    E1 e1;
    E2 e2;
    E[] range = [
        E("Abc","123",101),
        E("Def","456",102),
        E("ghi","789",103)
    ];
    Dir.linux_dirent64[] file_range;

    // elements
    import std.traits : ReturnType;
    ReturnType!(Select_2!(E1*,E2*)) select_2;
    _Select!(_Slice!(typeof(file_range))) select;

    //
    Pos_Size[]          mouse_sensable_pos_sizes;
    Mouse_Sensable.DG[] mouse_sensable_dgs;

    this (GL_Side gl_side) {
        this.gl_side = gl_side;
        this.gl_side._init ();
        this.gl_side.gl_view._init ();

/*
        this.select_2 = Select_2 (&e1, &e2, Pos (0,0), Size (640,400), Pad (50,50,50,50));
        //this.select = Select (range, Pos (0,0), Size (640,400), Pad (24,36,24,36));
        _load_dir ();
        this.select = Select (file_range, Pos (0,0), Size (640,400), Pad (24,36,24,36));
*/
    }


    //
    void
    _load_dir () {
        import std.string : fromStringz;

        auto d = Dir.open ("/");
        ubyte[] buffer;
        buffer.length = 1000;

        foreach (Dir.linux_dirent64* _dirent; d.read (buffer))
            file_range ~= *_dirent;
    }

    void
    draw (SDL_Renderer* renderer, SDL_Window* window) {
version (Android_or_linux) {
        //draw_scene
        // _clear_buffer
        glViewport (0, 0, 640, 480);
        glClearColor (0.2f, 0.2f, 0.2f, 1.0f);
        glClear (GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

        // _render_scene
        //gl_side.draw_char (GL_Side.Char_id ('A'));
        gl_side.draw_char_at (GL_Side.Char_id ('A'), 100, 100);

        // _update_window
        SDL_GL_SwapWindow (window);
}
else {

        //import std.range : back;

        // clear screen
        SDL_SetRenderDrawColor (renderer, 0x00, 0x00, 0x00, 0x00);
        SDL_RenderClear (renderer);
        // draw
        // SDL_SetRenderDrawColor (renderer,0xFF,0xFF,0xFF,0xFF);
        // SDL_RenderDrawPoint (renderer, x, y);
        // SDL_RenderDrawLine (renderer,0,0,100,100);
        // SDL_RenderFillRect (renderer,&rect);
        // SDL_RenderDrawRect (renderer,&rect);
        // ...

        // clear
        mouse_sensable_pos_sizes.length = 0;
        mouse_sensable_dgs.length       = 0;
        //select_2.draw (renderer);
        // collect moue sensable pos_size
        Draw_Return draw_return = select.draw (renderer);
        _collect_mouse_sensable_pos_size (draw_return.ms);

        // Load Resource
        // Resource.id
        // Resource conertor
        // Resource to draws
        //auto r = 
        //    Font!(ftlib)
        //        .open (font_pathname)
        //        .open (font_size)
        //        .open ('A')
        //        .read!E ();

        //foreach (e; r)
        //    log (e);

        //auto draws = 
        //    font_cache.get_draws (
        //        font_id, 
        //        cast (Fonts!Draws.Font_size) font_size, 
        //        cast (dchar) 'A'
        //    );

        //gl_side.__draw_draws (r);  // Font_Glyph.ID.Iterator!(Font_Glyph.ID.E)

        //Render (renderer)
        //    .render_char ('A');
        //Render (renderer)
        //    .render_chars (['A','B']);
        //Render (renderer)
        //    .render_chars ("Hi!");
        //Render (renderer)
        //    .render_int (123);
        //Render (renderer)
        //    .render_field!int (123);
        //Render (renderer)
        //    .render_field!string ("Hi!");
        //
        //struct 
        //Struct {
        //    int a;
        //    int b = 1;
        //    string c = "Hi!";
        //}
        //Struct _struct;
        //Render (renderer)
        //    .render_struct (_struct);

version (_DIR_GRID_) {
        import file : Dir;
        import std.string : fromStringz;
        import std.algorithm : sum;

        ubyte[] buffer;
        buffer.length = 1000;

        auto iterator =
            Dir
                .open ("/")
                .read (buffer);


        int  x,y;
        Size size;
        Pad  pad = Pad (10,10,10,10);

        size = 
            Render (renderer,x+pad.l,y+pad.t)
                .render_selection (
                    0,
                    0, 
                    [120,120,400].sum, 
                    64 + pad.t + pad.b
                );

        foreach (_dirent; iterator) {
            size = 
                Render (renderer,x+pad.l,y+pad.t)
                    .render_struct (_dirent, [120,120,400]);
            y += size.h + pad.t + pad.b;
            if (y > 640)
                break;
        }


        //auto r = [Struct(0,1),Struct(2,3)];

        //int x,y;
        //foreach (e; r) {
        //    auto size = 
        //        Render (renderer,x,y)
        //            .render_struct (e);

        //    y += size.h;
        //}

        // cahce
        // path -> cahce_id
        // arial/10/A -> cahce_id  - resource_id
        // look 
        //   in cache -> ok
        //   go path
        //     ok -> store copy in cache

        // fast mem
        // slow mem
    }

    struct
    E {
        Type    type;
        Point[] points;  // rel

        enum Type {
            POINTS,
            LINES,
            LINES2,
        }

        alias Point = SDL_Point;
    }
}
}


    void
    event (SDL_Event* e) {
        switch (e.type) {
            case SDL_MOUSEBUTTONDOWN:
                // ...
                break;
            case SDL_MOUSEMOTION:
                on_mouse_motion (&e.motion);
                break;
            default:
        }

        select_2.event (e);
        select.event (e);
    }


    void
    _collect_mouse_sensable_pos_size (ref Mouse_Sensable ms) {
        mouse_sensable_pos_sizes ~= ms.pss;
        mouse_sensable_dgs       ~= ms.dgs;
    }

    void
    on_mouse_motion (SDL_MouseMotionEvent* e) {
        auto pos = Pos (e.x,e.y);
        foreach (i,ref ps; mouse_sensable_pos_sizes) {
            if (ps.has_pos (pos)) {
                mouse_sensable_dgs[i] (ps,pos);
            }
        }
    }
}


//
import core.sys.posix.dirent : opendir,readdir_r,DIR,dirent,closedir;



// render
// pos,draws_id
// pos,resource_id
// [pos,resource_id],[pos,resource_id],...
// resources
//   draws[id]  // [type,points],[type,points],...  // points,lines,lines2
//
// m8   m8   m16
// byte byte short
// font size wchar
//
// char         - Cache     - GL_Side
//              - resource    draws
// resource_id -> cache    -> resource.draws
//
// draw_A
//   look cache -> draws
//     OK:   
//       _draw draws
//     FAIL: 
//       draws > cache
//       _draw draws


alias Draws = GL_Side._char;

struct
Resources {
    Resource[dchar] s;
    alias s this;
}

struct
Resource {
    Draws draws;
    alias draws this;
}


struct
Dir_Grid {
    // return
    //   this
    //   Mouse_Sensable[] = xywh[],cb
    //   Key_Sensable[] = &key_cb
    //   sense_cb (Sensable.id)

    // input
    //   check sensables
    //     if match (sensable, pointer.pos)
    //       sense_cb (sensable_id)

    // render on
    // render recursive
    // render grid as one
    // render row as one
    // render fields as one
    // render field as one

    // render
    // pos,draws_id
    // pos,resource_id
    // [pos,resource_id],[pos,resource_id],...
    // resources
    //   draws[id]  // [type,points],[type,points],...  // points,lines,lines2

	Dirent_ext[]  dir_s;
	Sensable[]    sensables;
	size_t        data_start_i;
	Col[]         cols;
	Dirent_ext[] _sensable_data_s;  // slice of dir_s

	enum grid_h = 600;
	enum grid_w = 480;
	enum sensable_h = 50;
	enum sensable_w = grid_w;

	alias Sensable_id = size_t;
    alias Resource_id = size_t;

	struct
	Col {
	    X start;
	    X width;
	}

	void
	load () {
        import  file : Dir;
        import  std.string : fromStringz;
        import  std.algorithm : sum;
        ubyte[] buffer;
        buffer.length = 1000;
        auto    iterator = Dir.open ("/").read (buffer);
	}

	void
	create_cols () {
	    cols ~= Col (0,50);
	    cols ~= Col (60,200);
	}

	void
	draw () {
version (linux) {
		X x = 0;
        Y y = 0;
		Resource_id resource_id;

        foreach (dir; dir_s) {
            if (y >= grid_h)
                break;

			// icon
			resource_id = 0;
			draw_resouce (resource_id, Pos (cols[0].start, y));

			// text
			resource_id = 1;
			draw_resouce (resource_id, Pos (cols[1].start, y));

	    	sensables ~= Sensable (Pos (x,y), Size (sensable_w,sensable_h));

            //
            y += sensable_h;
	    }
}
else {
        int  x,y;
        Size size;
        Pad  pad = Pad (10,10,10,10);

        size = 
            Render (renderer,x,y)
                .render_selection (0,0,[120,120,400].sum,50);

        foreach (_dirent; iterator) {
            size = 
                Render (renderer,x_pad.l,y+pad.t)
                    .render_struct (_dirent, [120,120,400]);

            y += size.h + pad.t + pad.b;

            if (y >= grid_h)
                break;
        }
}
	}

	auto
	sensable_id_to_data_id (Sensable_id sensable_id) {
		return data_start_i + sensable_id;
	}

	void
	draw_resouce (Resource_id resource_id, Pos pos) {
	    //
	}

    void
    draw_char (dchar c) {
        // char
        // font
        //   face
        //   size
        // glif
        // contur
        // points
    }

	void
	sense (Sensable_id sensable_id) {
		// dir_s
		// sensables
	}
}

struct
Sensable {
	Pos  pos;
	Size size;
}


struct
Dirent_ext {
    dirent _super;
    alias _super this;
}

//struct 
//dirent {
//    import core.sys.posix.sys.types : ino_t,off_t;
//    ino_t  d_ino;       /* inode number */
//    off_t  d_off;       /* offset to the next dirent */
//    ushort d_reclen;    /* length of this record */
//    ubyte  d_type;      /* type of file; not supported
//                           by all file system types */
//    char[256] d_name; /* filename */
//};

// text
//   start_pos
//   char
//     lines
//   char
//     lines
//   ...
//   width
//   width / 2 -> start_pos
//   at start
//   
// render icon
// render text
// start pos col1.start_x
// start pos col2.start_x



// не копировать, а
// запомнить / вспомнить
// mem / re-mem
