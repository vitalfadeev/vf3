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
// W_pos - pos on world (on psy)
// D_pos - pos on draw_na
// S_pos - pos on sensor

struct
D_pos {
    // VectorN!2
    X x;
    Y y;

    alias X = int;
    alias Y = int;
}

