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
    ESContext es_context;

    void
    _init () {
        es_context.userData = new UserData ();
        init_shaders (&es_context);
    }

    GLuint
    init_shaders (ESContext* es_context) {
        Shader_Id vertex_shader;
        Shader_Id fragment_shader;
        GLuint    program_object;
        GLint     linked;
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

        vertex_shader   = load_shader (GL_VERTEX_SHADER, vShaderStr);
        fragment_shader = load_shader (GL_FRAGMENT_SHADER, fShaderStr);

        // Create the program object
        program_object = glCreateProgram ( );
        
        if (program_object == 0)
           return 0;

        glAttachShader (program_object,vertex_shader);
        glAttachShader (program_object,fragment_shader);

        // Bind vPosition to attribute 0   
        glBindAttribLocation (program_object,0,"vPosition");

        // Link the program
        glLinkProgram (program_object);

        // Check the link status
        glGetProgramiv (program_object,GL_LINK_STATUS,&linked);

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

        // Store the program object
        userData.program_object = program_object;

        glClearColor (0.0f, 0.0f, 0.0f, 0.0f);
        return GL_TRUE;
    }


    Size
    draw_char (GL_Char* gl_char) {
        glViewport (0,0,640,480);

        glClearColor (0.2f, 0.2f, 0.2f, 1.0f);
        glClear (GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

        glUseProgram (draw_char_program);

        glVertexAttribPointer (0, 2, GL_FLOAT, GL_TRUE, 0, gl_char.gl_points.ptr);
        glEnableVertexAttribArray (0);

        foreach (ref gl_contur; gl_char.gl_conturs)
            glDrawArrays (GL_LINE_LOOP, gl_contur.first, gl_contur.count);

        return Size (gl_char.w,gl_char.h);
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

