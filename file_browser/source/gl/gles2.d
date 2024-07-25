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
    ESContext  es_context;

    void
    _init () {
        es_context.userData = new UserData ();
        init_shaders (&es_context);
    }

    GLuint
    init_shaders (ESContext* es_context) {
        Program_Id program_id;
        UserData* userData = cast (UserData*) es_context.userData;

        string vShaderStr =  
           "attribute vec4 vPosition;    \n" ~
           "void main()                  \n" ~
           "{                            \n" ~
           "   gl_Position = vPosition;  \n" ~
           "}                            \n";
        
        string fShaderStr =  
           //"precision mediump float;\n" ~
           "void main()                                  \n" ~
           "{                                            \n" ~
           "  gl_FragColor = vec4 ( 1.0, 0.0, 0.0, 1.0 );\n" ~
           "}                                            \n";

        // Store the program object
        program_id = load_program (vShaderStr,fShaderStr);
        if (program_id == GL_FALSE)
            return GL_FALSE;

        userData.program_object = program_id;

        return GL_TRUE;
    }

    Program_Id 
    load_program (string vertShaderSrc, string fragShaderSrc) {
        Shader_Id  vertex_shader;
        Shader_Id  fragment_shader;
        Program_Id program_object;
        GLint      linked;

        // Load the vertex/fragment shaders
        vertex_shader = load_shader (GL_VERTEX_SHADER, vertShaderSrc);
        if (vertex_shader == 0)
           return 0;

        fragment_shader = load_shader (GL_FRAGMENT_SHADER, fragShaderSrc);
        if (fragment_shader == 0) {
           glDeleteShader (vertex_shader);
           return 0;
        }

        // Create the program object
        program_object = glCreateProgram ();
        
        if (program_object == 0)
           return 0;

        glAttachShader (program_object, vertex_shader);
        glAttachShader (program_object, fragment_shader);

        // Link the program
        glLinkProgram (program_object);

        // Check the link status
        glGetProgramiv (program_object, GL_LINK_STATUS, &linked);

        if (!linked) {
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

                throw new Exception ("Error linking program: \n" ~ info);
           }

           glDeleteProgram (program_object);
           return GL_FALSE;
        }

        // Free up no longer needed shader resources
        glDeleteShader (vertex_shader);
        glDeleteShader (fragment_shader);

        return program_object;
    }


    Shader_Id 
    load_shader (GLenum type, string shader_src) {
       Shader_Id shader;
       GLint     compiled;
       
       // Create the shader object
       shader = glCreateShader (type);

       if (shader == 0)
        return 0;

       // Load the shader source
       const GLchar* ptr = shader_src.ptr;
       glShaderSource (shader, 1, &ptr, null);
       
       // Compile the shader
       glCompileShader (shader);

       // Check the compile status
       glGetShaderiv (shader, GL_COMPILE_STATUS, &compiled);

       if (!compiled)  {
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

               throw new Exception ("Error compiling shader: \n" ~info ~ "\n" ~ shader_src);
          }

          glDeleteShader (shader);

          return 0;
       }

       return shader;
    }


    Size
    draw_char (GL_Char* gl_char) {
        glViewport (0,0,640,480);

        glClearColor (0.2f, 0.2f, 0.2f, 1.0f);
        glClear (GL_COLOR_BUFFER_BIT);

        glUseProgram (draw_char_program);

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
ESContext {
   void*               userData;   /// Put your user data here...
   GLint               width;      /// Window width
   GLint               height;     /// Window height
   //EGLNativeWindowType hWnd;       /// Window handle
   //EGLDisplay          eglDisplay; /// EGL display
   //EGLContext          eglContext; /// EGL context
   //EGLSurface          eglSurface; /// EGL surface
   /// Callbacks
   void function (ESContext*) drawFunc;
   void function (ESContext*, ubyte, int, int ) keyFunc;
   void function (ESContext*, float deltaTime ) updateFunc;
}

struct
UserData {
   GLuint program_object;  // Handle to a program object
}

