import group;
import pos;

struct
_E(DATA) {
    alias T = typeof(this);

    // Group data
    Groups!T _groups;  // Group[], e
    auto ref groups() { _groups._e = &this; return _groups; }

    // Place data
    Pos pos;

    // Layer data
    Layer layer;

    // Draw data
    Draw_id  draw_id;
}

alias Draw_id = ubyte;

alias Group_id = ubyte;

struct 
_ES(E) {
    E*[] s;
    alias s this;
}

//
alias DATA = int;
alias E    = ._E!DATA;
alias ES   = ._ES!E;

// Layer
struct
Layer {
    ubyte z;
    alias z this;
}

