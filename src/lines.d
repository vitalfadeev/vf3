import pos;

struct
Lines {
    Line[] lines;

    // line -> h_lines
    void
    h_line (Pos a, Pos b) {
        lines ~= Line (a,b);
    }

    void
    v_line (Pos a, Pos b) {
        auto x = a.x;

        typeof(a.y) start_y;
        typeof(a.y) limit_y;

        if (a.y < b.y) {
            start_y = a.y;
            limit_y = b.y;
        }
        else {
            start_y = b.y;
            limit_y = a.y;
        }

        for (auto y=start_y; y < limit_y; y++)
            lines ~= Line (Pos(x,y),Pos(x+1,y+1));
    }

    void
    v_line (Pos a, Pos b, int width) {
        auto x = a.x;

        typeof(a.y) start_y;
        typeof(a.y) limit_y;

        if (a.y < b.y) {
            start_y = a.y;
            limit_y = b.y;
        }
        else {
            start_y = b.y;
            limit_y = a.y;
        }

        for (auto y=start_y; y < limit_y; y++)
            lines ~= Line (Pos(x,y),Pos(x+1,y+1));
    }
}

struct
Line {
    Pos a;
    Pos b;
}
