import store;
import color;
import pos;


alias Draw_store = Store!Draws;
Draw_store draw_store;


struct
Draws {
    _Draw[] _super;
    alias _super this;
}

// Lines
struct
_Draw {
    Color color;
    Pos[] pos;
}
