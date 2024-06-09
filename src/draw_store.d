import store;
import color;
import pos;


//alias Draw_store = Store!Draws;
//Draw_store draw_store;


struct
Draws {
    _Draw[] _super;
    alias _super this;

    auto ref
    copy (ref Draws _copy) {
        foreach (ref rec; _super)
            _copy ~= _Draw (rec.color, rec.pos.dup);
        return _copy;
    }
}

// Lines
struct
_Draw {
    Color color;
    Pos[] pos;
}
