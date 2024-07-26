module gl.gles2;

import std.string;
import gl_side;
import types;


//import bindbc.gles.egl;
version (Android) {
public import bindbc.gles.gles;
}
else
version (linux) {
public import bindbc.opengl;
alias GLfixed = int;
}
else {
    static assert (0, "unsupported platform");
}

alias Program_Id = GLuint;
alias Shader_Id  = GLuint;

struct
GLES2 {
    Program_Id draw_char_program;
    Context    context;

    void
    _init () {
        context.user_data = new UserData (640,480);
        load_programs ();
    }

    void
    load_programs () {
        context.user_data.basic_program = 
            Program (
                "attribute vec4 vPosition;    \n" ~
                "void main()                  \n" ~
                "{                            \n" ~
                "   gl_Position = vPosition;  \n" ~
                "}                            \n"
            ,
                //"precision mediump float;\n" ~
                "void main()                                  \n" ~
                "{                                            \n" ~
                "  gl_FragColor = vec4 ( 1.0, 1.0, 1.0, 1.0 );\n" ~
                "}                                            \n"
            );


        context.user_data.matrix_program = 
            Program (
                "uniform mat4 u_mvpMatrix;                   \n" ~
                "attribute vec4 a_position;                  \n" ~
                "void main()                                 \n" ~
                "{                                           \n" ~
                "   gl_Position = u_mvpMatrix * a_position;  \n" ~
                "}                                           \n"
            ,
                //"precision mediump float;                            \n" ~
                "void main()                                         \n" ~
                "{                                                   \n" ~
                "  gl_FragColor = vec4( 1.0, 0.0, 0.0, 1.0 );        \n" ~
                "}                                                   \n"
            );
        
    }


    Size
    draw_char (GL_Char* gl_char) {
        glViewport (0,0,context.user_data.w,context.user_data.h);

        glClearColor (0.2f, 0.2f, 0.2f, 1.0f);
        glClear (GL_COLOR_BUFFER_BIT);

        glUseProgram (context.user_data.basic_program.id);

        glVertexAttribPointer (0, 2, GL_FLOAT, GL_TRUE, 0, gl_char.gl_points.ptr);
        glEnableVertexAttribArray (0);

        foreach (ref gl_contur; gl_char.gl_conturs)
            glDrawArrays (GL_LINE_LOOP, gl_contur.first, gl_contur.count);

        return Size (gl_char.w,gl_char.h);
    }


    GLfloat[] 
    _test_triangle_verts = [
         0.0f,  0.5f,
        -0.5f, -0.5f,
         0.5f, -0.5f,
    ];
}

struct 
Context {
   UserData*           user_data;   /// Put your user data here...
   GLint               width;      /// Window width
   GLint               height;     /// Window height
   //EGLNativeWindowType hWnd;       /// Window handle
   //EGLDisplay          eglDisplay; /// EGL display
   //EGLContext          eglContext; /// EGL context
   //EGLSurface          eglSurface; /// EGL surface
   /// Callbacks
   void function (Context*) drawFunc;
   void function (Context*, ubyte, int, int ) keyFunc;
   void function (Context*, float deltaTime ) updateFunc;
}

struct
UserData {
    // viewport
    int     w;
    int     h;
    // programs
    Program basic_program;
    Program matrix_program;
}


struct
Program {
    Program_Id id;

    this (string vShaderStr, string fShaderStr) {
        if (!load_program (vShaderStr,fShaderStr))
            this.id = 0;
    }

    bool
    load_program (string vertShaderSrc, string fragShaderSrc) {
        GLint linked;

        // Load the vertex/fragment shaders
        Shader vertex_shader;
        Shader fragment_shader;
        try {
            vertex_shader   = Shader (GL_VERTEX_SHADER, vertShaderSrc);
            fragment_shader = Shader (GL_FRAGMENT_SHADER, fragShaderSrc);
        } catch (Exception e) {            
            if (vertex_shader.id != 0) {
               glDeleteShader (vertex_shader.id);
               throw e;
            }
        }

        // Create the program object
        auto program_id = glCreateProgram ();
        
        if (program_id == 0)
           throw new Exception ("glCreateProgram");

        glAttachShader (program_id, vertex_shader.id);
        glAttachShader (program_id, fragment_shader.id);

        // Link the program
        glLinkProgram (program_id);

        // Check the link status
        glGetProgramiv (program_id, GL_LINK_STATUS, &linked);

        if (!linked)
            throw new Program_Exception (program_id, "glGetProgramiv");

        // Free up no longer needed shader resources
        glDeleteShader (vertex_shader.id);
        glDeleteShader (fragment_shader.id);

        this.id = program_id;
        return true;
    }

    class 
    Program_Exception : Exception {
        this (Program_Id program_object, string msg) {
            GLint info_len = 0;

            glGetProgramiv (program_object,GL_INFO_LOG_LENGTH,&info_len);

            if (info_len > 1) {
                 string info;
                 info.length = info_len;

                 glGetProgramInfoLog (
                     program_object, 
                     info_len, 
                     null, 
                     cast (char*) info.ptr
                 );

                 info.length--;

                 glDeleteProgram (program_object);
                 super (msg ~ ": Error linking program: \n" ~ info);
            }
            else {
                glDeleteProgram (program_object);
                super (msg);
            }
        }
    }}


struct
Shader {
    Shader_Id id;

    this (GLenum type, string shader_src) {
        if (!load_shader (type,shader_src))
            this.id = 0;
    }

    bool 
    load_shader (GLenum type, string shader_src) {
        Shader_Id shader;
        GLint compiled;
       
        // Create the shader object
        shader = glCreateShader (type);

        if (shader == 0)
            throw new Exception ("glCreateShader");

        // Load the shader source
        const GLchar* ptr = shader_src.ptr;
        glShaderSource (shader, 1, &ptr, null);
       
        // Compile the shader
        glCompileShader (shader);

        // Check the compile status
        glGetShaderiv (shader, GL_COMPILE_STATUS, &compiled);

        if (!compiled)
            throw new Shader_Exception (shader,"glGetShaderiv",shader_src);

        this.id = shader;
 
        return true;
    }    

    class 
    Shader_Exception : Exception {
        this (Shader_Id shader, string msg, string shader_src) {
             GLint info_len = 0;

             glGetShaderiv (shader, GL_INFO_LOG_LENGTH, &info_len);
               
             if (info_len > 1) {
                 string info;
                 info.length = info_len;

                 glGetShaderInfoLog (
                     shader, 
                     info_len, 
                     null, 
                     cast (char*) info.ptr
                 );

                 info.length--;

                 glDeleteShader (shader);
                 super (msg ~ ": Error compiling shader: \n" ~info ~ "\n" ~ shader_src);
             }
             else {
                glDeleteShader (shader);
                super (msg);
             }
       }
    }
}
