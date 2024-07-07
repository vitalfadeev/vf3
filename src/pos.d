// Place
struct
Pos {
    // VectorN!2
    X x;
    Y y;

    alias X = int;
    alias Y = int;
}

alias W_pos = Pos;
// D_pos - pos on draw_na         LO res  16,16 bit
// W_pos - pos on world (on psy)  HI res  32,32 bit
// S_pos - pos on sensor
//
// G_pos - pos on glyph                    8,8 bit

struct
D_pos {
    // VectorN!2
    X x;
    Y y;

    alias X = short;
    alias Y = short;
}

struct
S_pos {
    // VectorN!2
    X x;
    Y y;

    alias X = short;
    alias Y = short;
}

struct
G_pos {
    // VectorN!2
    X x;
    Y y;

    alias X = byte;
    alias Y = byte;
}

//
// When mouse click - pos in center: Pos.center () = (0,0)
//
