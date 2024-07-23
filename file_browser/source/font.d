import std.string : toStringz,fromStringz;
import std.stdio : writeln;
import std.range : back;
import bindbc.freetype;
import gl_side;
import errno_exception;
alias log=writeln;

enum font_dpi = 96;

FT_Library ftlib;


struct 
Font {
    static
    ID
    open (string pathname, int size, dchar index) {
        return ID (pathname,size,index);
    }

    struct
    ID {
        FT_Face fd;
        string  pathname;
        dchar   index;
        int     size;

        this (string pathname, int size, dchar index) {
            this.pathname = pathname;
            this.size     = size;
            this.index    = index;
        }

        Iterator
        read (ubyte[] buffer=null) {
            return Iterator (fd,pathname,size,index);
        }

        struct
        E {
            Contur[] s;
            int w;
            int h;

            struct
            Contur {
                Type    type;
                Point[] points;  // rel
                int     base_x;
                int     base_y;

                enum Type {
                    POINTS,
                    LINES,
                    LINES2,
                }

                alias Point = GL_Side.Point;
            }
        }

        struct 
        Iterator {
            FT_Face           fd;
            string            pathname;
            int               size;
            dchar             index;
            FT_Outline_Funcs _callbacks = {
                &move_to_cb,
                &line_to_cb,
                &coni_to_cb,
                &cubi_to_cb
            };

            E e;

            alias DG = int delegate (E e);
            alias front = e;

            int 
            opApply (scope DG dg) {
                _open ();
                e.w = cast (int) fd.glyph.metrics.horiAdvance/64;
                e.h = cast (int) fd.glyph.metrics.vertAdvance/64;

                auto _err = FT_Outline_Decompose (&fd.glyph.outline,&_callbacks,&this);
                
                if (_err)
                    throw new Exception ("FT_Outline_Decompose");

                int result = dg (e);
                if (result)
                    return result;

                return 0;
            }    

            extern (C)
            nothrow
            static
            int
            move_to_cb (const FT_Vector* to, void* _self) {
                auto self = cast (Iterator*) (_self);

                //FT_Pos x = to.x / 64;
                //FT_Pos y = to.y / 64;

                self.e.s ~= E.Contur (E.Contur.Type.LINES);
                self.e.s.back.points ~= E.Contur.Point (cast (int) to.x/64,self.size-cast (int) to.y/64);

                return 0;
            }

            extern (C)
            nothrow
            static
            int
            line_to_cb (const FT_Vector* to, void* _self) {
                auto self = cast (Iterator*) (_self);

                self.e.s.back.points ~= E.Contur.Point (cast (int) to.x/64,self.size-cast (int) to.y/64);

                return 0;
            }

            extern (C)
            nothrow
            static
            int
            coni_to_cb (const FT_Vector* control, const FT_Vector* to, void* _self) {
                auto self = cast (Iterator*) (_self);

                FT_Pos controlX = control.x;
                FT_Pos controlY = control.y;

                self.e.s.back.points ~= E.Contur.Point (cast (int) to.x/64,self.size-cast (int) to.y/64);

                return 0;
            }

            extern (C)
            nothrow
            static
            int
            cubi_to_cb (const FT_Vector* controlOne,
                            const FT_Vector* controlTwo,
                            const FT_Vector* to,
                            void *_self) {
                auto self = cast (Iterator*) (_self);

                FT_Pos controlOneX = controlOne.x;
                FT_Pos controlOneY = controlOne.y;

                FT_Pos controlTwoX = controlTwo.x;
                FT_Pos controlTwoY = controlTwo.y;

                self.e.s.back.points ~= E.Contur.Point (cast (int) to.x/64,self.size-cast (int) to.y/64);

                return 0;
            }

            void
            _open () {
                _open_pathname ();
                _open_size ();
                _open_index ();
            }

            void
            _open_pathname () {
                auto error = FT_New_Face (ftlib,pathname.toStringz,0,&fd);

                if (error == FT_Err_Unknown_File_Format) {
                    //... the font file could be opened and read, but it appears
                    //... that its font format is unsupported
                }
                else 
                if (error) {
                    //... another error code means that the font file could not
                    //... be opened or read, or that it is broken...
                }
            }

            void
            _open_size () {
                FT_Set_Char_Size (fd, 0, size * 64, font_dpi, font_dpi);
            }

            void
            _open_index () {
                FT_Load_Glyph (fd, FT_Get_Char_Index (fd,index), FT_LOAD_DEFAULT);
            }

        }

        void
        close () {
            FT_Done_Face (fd);
        }
    }
}

unittest {
    // "arial/24/A"
    // open ("arial/24/A")
    // open ("arial",24, 'A')
    auto font = Font.open (pathname,size,c);

        .cache (Cache_id (style.font_pathname,style.font_size,c))
        .draw_draws (renderer,pos,render_flags)  // Font_Glyph.ID.Iterator!(Font_Glyph.ID.E)
        ;
}
