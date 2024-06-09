import el : E;
import pos;

struct
Group (E) {
    alias T = typeof (this);
    alias GO = void function (T* _this);

    GO         go = &_go;
    Group_es!E es;

    static void
    _go (T* _this) {
        foreach (ref e; _this.es)
            {} // e.pos = Pos (0,0);
    }
}


struct
Egroups (E) {
    alias G = Group!E;

    G*[] _super;
    alias _super this;

    E*   _e;
    
    //int
    //opApply (int delegate(ref size_t, ref Group!E*) dg) {
    //    int result = 0;

    //    foreach (size_t i, g; _super) {
    //        result = dg (i,g);

    //        if (result) {
    //            break;
    //        }
    //    }

    //    return result;
    //}

    void 
    opOpAssign (string op: "~") (G* group) { 
        _super ~= group;
        group.es ~= _e;
    }
}


struct
_GS (G) {
    G*[] _super;
    alias _super this;
}

alias GS = ._GS!(Group!E);


struct
Group_es (E) {
    E*[] _super;
    alias _super this;

    void
    opOpAssign (string op : "~") (E* b) {
        _super ~= b;
        //b.groups ~= this;
    }
}


struct 
Pos_control_group (E) {
    alias T = typeof (this);
    alias GO = void function (T* _this);

    GO         go = &_go;
    Group_es!E es;

    void
    cb (E* e) {
        //
    }

    static void
    _go (T* _this) {
        foreach (ref e; _this.es)
            cb (e); // e.pos = Pos (0,0);
    }
}


struct
Ryadki_group (E,int IN_RYAD=3,int RYADOV=2) {
    alias T = typeof (this);
    alias GO = void function (T* _this);

    GO         go = &_go;
    Group_es!E es;

    static void
    _go (T* _this) {
        int in_ryad = IN_RYAD;
        int ryadov  = RYADOV;

        int dx = 100;
        int dy = 100;
        int x  = 0;
        int y  = 0;

        foreach (ref e; _this.es) {
            e.pos = Pos (x,y);

            x += dx;

            //
            in_ryad --;

            if (in_ryad == 0) {
                ryadov --;
                x  = 0;
                y += dy;
            }

            if (ryadov == 0)
                break;
        }
    }
}
