import bindbc.sdl;
import std.range : ElementType;
import types;
import std.stdio : writeln;
alias log = writeln;

//import bindbc.gles.egl;
version (Android) {
public import bindbc.gles.gles;
alias glGenVertexArraysOES = glGenVertexArrays;
alias glBindVertexArrayOES = glBindVertexArray;
}
else {
public import bindbc.opengl;
alias glGenVertexArraysOES = glGenVertexArrays;
alias glBindVertexArrayOES = glBindVertexArray;
alias GLfixed = int;
}



struct
GL_Side {
    // Resources
    //   ( (type,points[]) [] ) [id]   <- for char
    //   type,points
    //   type,rel_points  // Bytes
    //
    //   (move,id) []
    //   (abs_move_pos,id) []          <- for string
    //    
    alias ID = dchar;

    SDL_Renderer* renderer;
    _mix[ID]      s;  // resources


    alias ABSXY    = SDL_Point;
    alias RELXY    = SDL_Point;
    alias Point    = SDL_Point;
    alias Pos      = SDL_Point;

    struct 
    Pos_Size {
        Pos  pos;
        Size size;

        bool
        has_pos (Pos _pos) {
            if (_pos.x >= this.pos.x && _pos.y >= this.pos.y)
            if (_pos.x < pos.x + this.size.w && _pos.y < this.pos.y + this.size.h)
                return true;

            return false;
        }
    }

    struct
    XYWH {
        X x;
        Y y;
        W w;
        H h;
    }

    struct
    Size {
        X w;
        Y h; 

        void
        opOpAssign (string op : "+") (Size b) {
            this.w += b.w;
            this.h += b.h;
        }

        Size
        opBinary (string op : "+") (Pad b) {
            return 
                Size (
                    this.w + b.l + b.r, 
                    this.h + b.t + b.b
                );
        }
    }

    struct 
    Pad {
        int t;
        int r;
        int b;
        int l;
    }

    alias X=int;
    alias Y=int;
    alias W=int;
    alias H=int;

    //struct
    //ABSXY {  // 16,16
    //    short x;
    //    short y;
    //}

    //struct
    //RELXY {  // 8,8
    //    byte x;
    //    byte y;
    //}

    void
    draw (ID id) {
        _draw_mix (id);
    }

    void
    load_font_resource () {
        //
    }

    void
    load_image_resource () {
        //
    }

    void
    draw_char (ID id, _char draws) {
        _add_char (id,draws);
        _draw_draws (draws);
    }

    void
    draw_string (ID[] ids, ABSXY[] xys) {
        _add_string (ids,xys);
        //_draw_draws (draws);
    }

    void
    _add_char (ID char_id, _char draws) {
        s[char_id] = _mix ([_mix.Rec (_mix.Rec.Type.CHAR, draws)]);
    }

    void
    _add_string (ID[] ids, ABSXY[] xys) {
        _string.Rec[] recs;
        recs.length = ids.length;

        foreach (i,id; ids)
            recs[i] = _string.Rec (xys[i],id);

        _add_string (recs);
    }

    void
    _add_string (_string.Rec[] recs) {
        ID char_id = _new_id ();
        s[char_id] = _mix ([_mix.Rec (_mix.Rec.Type.STRING, _string (recs))]);
    }

    ID
    _new_id () {
        static ID _last_id;
        _last_id++;
        return _last_id;
    }

    void 
    _draw_mix (ID id) {
        auto m = id in s;

        if (m !is null) {
            _draw_mix (m);
        }
    }

    void 
    _draw_mix (_mix* m) {
        foreach (ref rec; m.s) {
            switch (rec.type) {
                case _mix.Rec.Type.CHAR:   _draw_char   (&rec.c); break;
                case _mix.Rec.Type.STRING: _draw_string (&rec.s); break;
                default:
            }
        }
    }

    void
    _draw_char (ID char_id) {
        auto m = _get_char_draws (char_id);
        if (m !is null) {
            _draw_mix (m);
        }
    }

    void 
    _draw_char (_char* cc) {
        _draw_draws (*cc);
    }

    void 
    _draw_string (_string* ss) {
        foreach (ref rec; ss.s) {
            _move_g_cursor (rec.abs_move_pos);
            _draw_char (rec.c);
        }
    }

    void
    _move_g_cursor (ABSXY pos) {
        // pos
    }

    void
    __draw_draws (R) (R range) {
        alias E = ElementType!R;

        foreach (e; range) 
            final
            switch (e.type) {
                case E.Type.POINTS: 
                    SDL_RenderDrawPoints (renderer,e.points.ptr,cast (int) e.points.length);
                    break;
                case E.Type.LINES: 
                    SDL_RenderDrawLines (renderer,e.points.ptr,cast (int) e.points.length);
                    break;
                case E.Type.LINES2: 
                    // ...
                    break;
            }
    }

    void
    _draw_draws (_char draws) {
        foreach (ref rec; draws.s) 
            switch (rec.type) {
                case _char.Rec.Type.POINTS: 
                    SDL_RenderDrawPoints (renderer,rec.points.ptr,cast (int) rec.points.length);
                    break;
                case _char.Rec.Type.LINES: 
                    SDL_RenderDrawLines (renderer,rec.points.ptr,cast (int) rec.points.length);
                    break;
                case _char.Rec.Type.LINES2: 
                    break;
                default:
            }
    }

    _mix*
    _get_char_draws (ID char_id) {
        return char_id in s;
    }

    //SDL_Point[]
    //to_sdl_points (RELXY[] points) {
    //    SDL_Point[] sdl_points;
    //    sdl_points.length = points.length;

    //    foreach (i,p; points) 
    //        sdl_points[i] = SDL_Point (p.x,p.y);

    //    return sdl_points;
    //}

    struct
    _char {
        Rec[] s;

        struct 
        Rec {
            Type    type;
            RELXY[] points;  // rel

            enum Type {
                POINTS,
                LINES,
                LINES2,
            }
        }
    }

    struct
    _string {
        Rec[] s;

        struct 
        Rec {            
            ABSXY abs_move_pos;  // abs
            ID    c;
        }
    }

    struct
    _mix {
        Rec[] s;

        struct
        Rec {
            Type type;
            union {                
                _char   c;
                _string s;
            }

            enum Type {
                CHAR,
                STRING,
            }

            this (Type type, _char c) {
                this.type = type;
                this.c = c;
            }

            this (Type type, _string s) {
                this.type = type;
                this.s = s;
            }
        }
    }

version (_RESOURCE_CB) {
    //
    GL_Buffer_Ids[Resource_Id] _gl_uploaded_buffers;
    alias SLOW_MEM_CB = Resource delegate (Resource_Id);
    struct
    GL_Buffer_Ids {
        GL.Buffer_Id[] s;
    }
    struct
    Resource {
        E[] s;

        struct
        E {
            Type     type;     // LINES
            Vertex[] vertexes; // 
        }
    }
    void
    draw_resource (int id, SLOW_MEM_CB slow_mem_cb) {
        auto buffer_ids = id in _gl_uploaded_buffers;
        if (buffer_ids is null) {
            resource = slow_mem_cb (id);
            buffer_ids = GL.Upload_Resource (resource);
              buffer_ids = [
                buffer_id = GL.CreateBuffer (vertexes[0]),
                buffer_id = GL.CreateBuffer (vertexes[1]),
              ];
            _gl_uploaded_buffers[id] = buffer_ids;
        }

        _draw_resource (buffer_id);
    }

    void
    _draw_resource (ref Buffer_Id buffer_id) {
        // buffer_id
        //   GL.select_buffer (buffer_id)
        // GL.DrawArray LINES
    }
}
}


enum Render_Flags : int {
    NO_RENDER_SIZE_ONLY = 0b0000_0001,
}


struct
Resource {
    //
}

struct
Fast_Mem {
    //
}

struct
Slow_Mem {
    //
}


Size
draw_draws (R) (R range, SDL_Renderer* renderer, Pos pos, int flags=0) {
    alias E = ElementType!R;
    alias Contur = E.Contur;

    foreach (e; range) {        
        if (flags & Render_Flags.NO_RENDER_SIZE_ONLY)
            return Size (e.w,e.h);

        // 
        foreach (contur; e.s) {
            // move points
            auto points = contur.points.dup;
            foreach (ref p; points) {
                p.x += pos.x;
                p.y += pos.y;
            }

            final
            switch (contur.type) {
                case Contur.Type.POINTS: 
                    SDL_RenderDrawPoints (renderer,points.ptr,cast (int) points.length);
                    break;
                case Contur.Type.LINES: 
                    SDL_RenderDrawLines (renderer,points.ptr,cast (int) points.length);
                    break;
                case Contur.Type.LINES2: 
                    // ...
                    break;
            }
        }

        return Size (e.w,e.h);
    }

    return Size ();
}



SDL_Rect
to_SDL_Rect (Pos pos, Size size) {
    return SDL_Rect (pos.x,pos.y,size.w,size.h);
}

SDL_Rect
to_SDL_Rect (Pos_Size pos_size) {
    return SDL_Rect (pos_size.pos.x,pos_size.pos.y,pos_size.size.w,pos_size.size.h);
}

/*
// GLES2.gl2
// Fixed_16_16  is 32 bit signed 16-bit fraction
//
// vertex array
// GL_POINTS, 
// GL_LINES, GL_LINE_LOOP, GL_LINE_STRIP, 
// GL_TRIANGLES, GL_TRIANGLE_STRIP, GL_TRIANGLE_FAN
//
// RGBA
//
// ubyte,ushort indexing
//
// VertexAttribPointer ()
void 
glVertexAttribPointer (
   GLuint indx, GLint size, GLenum type, 
   GLboolean normalized, GLsizei stride, const(GLvoid)* ptr);
void
// size
//   1,2,3,4
// type
//   GL_BYTE
//   GL_SHORT
//   GL_FIXED

glDrawArrays (GLenum mode, GLint first, GLsizei count);
// mode
//   GL_POINTS, GL_LINES, GL_LINE_LOOP, GL_LINE_STRIP,
//   GL_TRIANGLES, GL_TRIANGLE_STRIP, GL_TRIANGLE_FAN, 
//

void 
glEnableVertexAttribArray (GLuint index);

// client-size Array -> server-side Buffer
void 
glBindBuffer (GLenum target, GLuint buffer);
void 
glDeleteBuffers (GLsizei n, const(GLuint)* buffers);
void 
glGenBuffers (GLsizei n, GLuint* buffers);
void 
glBufferData (GLenum target, GLsizeiptr size, const(GLvoid)* data, GLenum usage);
void 
glBufferSubData (GLenum target, GLintptr offset, GLsizeiptr size, const(GLvoid)* data);

// coord transform
void 
glDepthRangef (GLclampf zNear, GLclampf zFar);
void 
glViewport (GLint x, GLint y, GLsizei width, GLsizei height);

// color
void 
glFrontFace (GLenum mode);

// vertex shaders
void 
glShaderSource (GLuint shader, GLsizei count, in GLchar** string, const(GLint)* length);
void 
glCompileShader (GLuint shader);
void 
glGetShaderInfoLog (GLuint shader, GLsizei bufsize, GLsizei* length, GLchar* infolog);
void 
glReleaseShaderCompiler ();
void 
glShaderBinary (GLsizei n, const(GLuint)* shaders, GLenum binaryformat, const(GLvoid)* binary, GLsizei length);
GLuint 
glCreateShader (GLenum type);

//
void 
glGetActiveUniform (GLuint program, GLuint index, GLsizei bufsize, GLsizei* length, GLint* size, GLenum* type, GLchar* name);
void 
glUseProgram (GLuint program);

// line width
void 
glLineWidth (GLfloat width);

// Whole framebuffer
void 
glClear (GLbitfield mask);
void 
glClearColor (GLclampf red, GLclampf green, GLclampf blue, GLclampf alpha);
*/



// void Vertex 234 sifd v (T coords)
// GLint
// glGetVertexAttribiv
// glGetVertexAttribPointerv
// glVertexAttrib1f 

//
// glGetError (void)

struct
GL_View {
    // https://github.com/Samsung/tizen-docs/blob/master/docs/application/native/guides/graphics/creating-opengles.md

    Appdata ad;

    struct 
    Appdata {
        Evas_Object *win;
        Evas_Object *conform;
        Evas_Object *label;
        alias Evas_Object = void;

        SDL_Window* window;
        void*       view;
        GLsizei     w=640;
        GLsizei     h=480;
        Model       model;
        Pos         anglePoint;
        int         window_rotation;
        float[]     mvp;
        GLuint      program;
        GLuint      vbo;
        GLuint      vao;
    };

    struct 
    Model {
        Vert[] s;
    }

    struct 
    Vert {
        E x;
        E y;

        alias E          = GLbyte;

        static if (is (E == GLfixed))
            alias GL_E   = GL_FIXED;
        else
        static if (is (E == GLbyte))
            alias GL_E   = GL_BYTE;
        else
        static if (is (E == GLshort))
            alias GL_E   = GL_SHORT;
        else
        static if (is (E == GLint))
            alias GL_E   = GL_INT;
        else
        static if (is (E == GLfloat))
            alias GL_E   = GL_FLOAT;
        else
            static assert (0,"unsupported planform");

        static if (is (GL_E == GL_FIXED))
            alias NORMALIZED = GL_FALSE;  // GL_FALSE for  GL_FIXED
        else
            alias NORMALIZED = GL_TRUE;  // GL_FALSE for  GL_FIXED
        //alias E    = GLfloat;
        //alias GL_E = GL_FLOAT;
    }


    void
    _init () {
        _init_glview ();
    }

    void
    _eln_callbacks () {
        // Initialization callback
        auto cb1 = &_init_glview;
        // Resizing callback
        auto cb2 = &_resize_glview;
        // Drawing callback
        auto cb3 = &_draw_glview;
        // Deletion callback
        auto cb4 = &_del_glview;
    }

    // OpenGL ES init callback 
    void
    _init_glview () {
        // Set OpenGL ES state color to pink 
        glClearColor (1.0, 0.2, 0.6, 1.0);

        // Do any form of OpenGL ES initialization here 
        _init_shaders(); 
        _init_vertices();
    }

    void
    _init_shaders () {
version (Android) {
        // Shader sources
        const GLchar* vertexSource =
            "attribute vec2 posi;         \n" ~
            "void                         \n" ~
            "main() {                     \n" ~
            "   gl_Position = vec4 (posi.xy, 0.0, 1.0); \n" ~
            "}                            \n";

        const GLchar* fragmentSource =
            "precision mediump float;\n" ~
            "void                                         \n" ~
            "main() {                                     \n" ~
            "  gl_FragColor = vec4 (1.0, 1.0, 1.0, 1.0);  \n" ~
            "}                                            \n";
}
else 
version (linux) {
    // Shader sources
    const GLchar* vertexSource =
        "#version 330                                   \n" ~
        "layout (location = 0) in vec2 position;        \n" ~
        "void                                           \n" ~
        "main () {                                      \n" ~
        "   gl_Position = vec4 (position, 0.0, 1.0);    \n" ~
        "}                                              \n";

    const GLchar* fragmentSource =
        "#version 330                                 \n" ~
        "void                                         \n" ~
        "main () {                                    \n" ~
        "  outColor = vec4 (1.0, 1.0, 1.0, 1.0);      \n" ~
        "}                                            \n";
}
else {
    assert (0, "unsupported planform");
}
        // 0. Program
        // Create and compile the vertex shader
        GLuint vertexShader = glCreateShader (GL_VERTEX_SHADER);
        glShaderSource (vertexShader,1,&vertexSource,null);
        glCompileShader (vertexShader);

        // Create and compile the fragment shader
        GLuint fragmentShader = glCreateShader (GL_FRAGMENT_SHADER);
        glShaderSource (fragmentShader,1,&fragmentSource,null);
        glCompileShader (fragmentShader);

        // Link the vertex and fragment shader into a shader program
        GLuint shaderProgram = glCreateProgram();
        glAttachShader (shaderProgram,vertexShader);
        glAttachShader (shaderProgram,fragmentShader);
        // glBindFragDataLocation(shaderProgram, 0, "outColor");
        glLinkProgram (shaderProgram);


        // 1. Buffer
        // Create a Vertex Buffer Object and copy the vertex data to it
        GLuint vbo;
        glGenBuffers (1,&vbo);  // 1 buffer

        //ad.model = Model ([
        //    Vert (   0, 0.4),
        //    Vert ( 0.4, 0.4),
        //    Vert ( 0.4,   0),
        //]);

        ad.model = Model ([
            Vert (   0, 120),
            Vert ( 120, 120),
            Vert ( 120,   0),
        ]);

        glBindBuffer (GL_ARRAY_BUFFER, vbo);
        glBufferData (GL_ARRAY_BUFFER, ad.model.s.length*Vert.sizeof, ad.model.s.ptr, GL_STATIC_DRAW);


        // 2. Ray
        // Create Vertex Array Object
        GLuint vao;
        glGenVertexArraysOES (1,&vao); // 1 array
        glBindVertexArrayOES (vao);


        // 3. vars
        // Specify the layout of the vertex data
        GLint posAttrib = glGetAttribLocation (shaderProgram,"position");
        log ("posAttrib: ", posAttrib);
        posAttrib = 0;
        glEnableVertexAttribArray (posAttrib);
        glVertexAttribPointer (posAttrib, Vert.tupleof.length, Vert.GL_E, Vert.NORMALIZED, Vert.sizeof, null);

        ad.program = shaderProgram;
        ad.vbo = vbo;
        ad.vao = vao;
    }

    void
    _init_vertices () {
        //matrix;
    }

    // GLView resize callback 
    static void
    _resize_glview () {
        int w;
        int h;
        //elm_glview_size_get (glview, &w, &h);
        glViewport (0, 0, w, h);
    }

    // OpenGL ES draw callback
    //static 
    void
    _draw_glview () {
        // Paint it pink 
        //glClear (GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

        // Usual OpenGL ES draw commands come here 
        _draw_scene(); 
    }

    // GLView deletion callback
    static void
    _del_glview () {
        /* Destroy all the OpenGL ES resources here */
        /* destroy_shaders(); */
        /* destroy_objects(); */
    }

    void
    _draw_scene () {
        _clear_buffer ();
        _render_scene ();
        _update_window ();
    }

    // https://docs.tizen.org/application/native/guides/graphics/sdl-opengles/#render
    void
    _clear_buffer () {
        glViewport (0, 0, ad.w, ad.h);
        glClearColor (0.2f, 0.2f, 0.2f, 1.0f);
        glClear (GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    }

    void
    _render_scene () {
        _init_matrix (ad.model);
        _rotate_xyz (ad.model, ad.anglePoint.x, ad.anglePoint.y, ad.window_rotation);
        _multiply_matrix (ad.mvp, ad.view, ad.model);

        glUseProgram (ad.program);
        glBindVertexArray (ad.vao);
        //glDrawArrays (GL_TRIANGLES, 0, cast (GLsizei) (ad.model.s.length));
        glDrawArrays (GL_LINE_LOOP, 0, cast (GLsizei) (ad.model.s.length));
    }

    void
    _init_matrix (Model model) {
        //
    }

    void
    _rotate_xyz (Model model, int anglePoint_x, int anglePoint_y, int window_rotation) {
        //
    }

    void
    _multiply_matrix (ref float[] mvp, void* view, Model model) {
        //
    }

    void
    _update_window () {
        SDL_GL_SwapWindow (ad.window);
    }    
}

void
init_gl (SDL_Window* window,SDL_GLContext glc) {
version (Android) {
    SDL_GL_SetAttribute (SDL_GL_CONTEXT_PROFILE_MASK, SDL_GL_CONTEXT_PROFILE_ES);
    SDL_GL_SetAttribute (SDL_GL_CONTEXT_MAJOR_VERSION,2);
    SDL_GL_SetAttribute (SDL_GL_CONTEXT_MINOR_VERSION, 0);
    SDL_GL_SetAttribute (SDL_GL_DOUBLEBUFFER,1);
    SDL_GL_SetAttribute (SDL_GL_DEPTH_SIZE,24);    
    SDL_GL_SetAttribute (SDL_GL_ACCELERATED_VISUAL,1);
}
else
version (linux) {
    SDL_GL_SetAttribute (SDL_GL_CONTEXT_FLAGS, 0);
    SDL_GL_SetAttribute (SDL_GL_CONTEXT_PROFILE_MASK, SDL_GL_CONTEXT_PROFILE_CORE);
    SDL_GL_SetAttribute (SDL_GL_CONTEXT_MAJOR_VERSION, 3);
    SDL_GL_SetAttribute (SDL_GL_CONTEXT_MINOR_VERSION, 0);
    SDL_GL_SetAttribute (SDL_GL_DOUBLEBUFFER, 1);
    SDL_GL_SetAttribute (SDL_GL_DEPTH_SIZE, 24);
    SDL_GL_SetAttribute (SDL_GL_STENCIL_SIZE, 8);
}
else {
    assert (0, "unsupported platform");
}

    // import bindbc.gles.egl;
    // loadEGL()
    //   libEGL.so
    //
    // import bindbc.gles.gles;
    // loadGLES ();
    //   libGLESv2.so
    // Create context for OpenGL window

version (Android) {
    import bindbc.gles.gles;

    GLESSupport ret = loadGLES();

    if (ret == GLESSupport.noLibrary) 
        throw new Exception ("The OpenGL shared library failed to load");
    else 
    if (ret == GLESSupport.badLibrary) 
        throw new Exception ("One or more symbols failed to load in OpenGL library");

    log (ret);
}
else 
version (linux) {
    //SDL_GL_LoadLibrary ("libGL.so");
    //SDL_GL_LoadLibrary ("libEGL.so");
    import bindbc.opengl;

    const GLSupport openglLoaded = loadOpenGL ();
    log (glSupport);
    if ( openglLoaded != glSupport) {
        import std.conv : to;
        log ("Error loading OpenGL shared library: ", to!string(openglLoaded));
        throw new Exception ("Error loading OpenGL shared library");
    }
}
else
version (__linux) {
    import bindbc.gles.egl;    

    EGLSupport ret = loadEGL();

    if (ret == EGLSupport.noLibrary) 
        throw new Exception ("The OpenGL shared library failed to load");
    else 
    if (ret == EGLSupport.badLibrary) 
        throw new Exception ("One or more symbols failed to load in OpenGL library");

    log (ret);
}
else {
    assert (0, "unsupported platform");
}
}
