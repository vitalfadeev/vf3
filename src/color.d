struct
Color {
    ARGB32 _a;

    ubyte
    r () {
        return (_a & 0xFF);
    }

    ubyte
    g () {
        return (_a & 0xFF00) >> 8;
    }

    ubyte
    b () {
        return (_a & 0xFF0000) >> 16;
    }

    ubyte
    a () {
        return (_a & 0xFF000000) >> 24;
    }
}

alias ARGB32 = uint;
