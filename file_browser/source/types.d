//module types;

import gl_side;

alias Pos      = GL_Side.Pos;
alias Size     = GL_Side.Size;
alias X        = GL_Side.X;
alias Y        = GL_Side.Y;
alias Pos_Size = GL_Side.Pos_Size;
alias Pad      = GL_Side.Pad;


//
struct
Mouse_Sensable {
    Pos_Size[] pss;
    DG[]       dgs;

    alias DG = void delegate (Pos_Size pos_size, Pos pos);
}

struct
Key_Sensable {
    DG dg;

    alias DG = void delegate ();
}

struct
Draw_Return {
    Pos_Size       ps;
    Mouse_Sensable ms;
}
