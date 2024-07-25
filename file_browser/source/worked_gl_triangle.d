version (__worked__):
void
__sample_1 () {
        glViewport (0,0,640,480);

        glClearColor (0.2f, 0.2f, 0.2f, 1.0f);
        glClear (GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

        glUseProgram (gl_view.ad.program);

        glVertexAttribPointer (0, 2, GL_FLOAT, GL_TRUE, 0, _test_triangle_verts.ptr);
        glEnableVertexAttribArray (0);
        glDrawArrays (GL_TRIANGLES, 0, 3);
        glDrawArrays (GL_LINE_LOOP, 0, 3);
}
