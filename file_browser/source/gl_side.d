import bindbc.sdl;
import std.range : ElementType;
import types;
import std.stdio : writeln;
alias log = writeln;


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
