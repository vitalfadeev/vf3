import color;
import pos;


struct
Glyph {
    G_lines _lines;

    auto ref
    lines () {
        return _lines;
    }
}

struct
G_lines {
    G_line[] _lines;

    G_lines_iter
    each () {
        return G_lines_iter (&this);
    }
}

struct
G_lines_iter {
    G_lines* ls;

    void
    draw (G) (G g) {
        foreach (ref l; ls._lines) {
            l.draw (g);
        }
    }
}


struct
G_line {
    Color color;
    G_pos a; // line includes a
    G_pos b; // line includes b
             // I click on a, I click on b -> line a-b inclues a,b

    void
    draw (G) (G g) {
        g.draw_line (a, b, color);
    }
}

