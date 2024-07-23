import std.stdio : writeln;
import std.range : ElementType;
import std.algorithm.searching : countUntil;
alias log = writeln;

auto Slice (R) (R range) {
    return _Slice!R (range,range);
}

struct
_Slice (R) {
    R _range;
    S _slice;
    alias _slice this;

    alias E = ElementType!R;
    alias S = typeof (_range[]);

    size_t selected;

    E front () { return E ();};

    size_t
    length () {
        return _slice.length;
    }

    void
    length (size_t a) {
        _slice.length = a;
    }

    E
    opIndex (size_t i) {
        return _slice[i];
    }


    //
    void
    select_down () {
        if (selected == _slice.length-1)
            scroll_up ();
        else
            selected++;
    }

    void
    select_up () {
        if (selected == 0)
            scroll_down ();
        else
            selected--;
    }

    void
    scroll_up () {
        if (_slice[$-1] != _range[$-1]) {
            auto i = _range.countUntil (_slice[0]);
            if (i != -1) {
                if (i == 0)
                    _slice = _range[1..$];
                else
                    _slice = _range[i+1..$];
            }
            else {
                _slice = _range[];
            }
        }
        else {
            //_slice = _range[];
            //selected = 0;
        }
    }

    void
    scroll_down () {
        if (_slice[0] == _range[0]) {
            //
        }
        else {
            auto i = _range.countUntil (_slice[0]);
            if (i != -1) {
                if (i == 0)
                    _slice = _range[0..$];
                else
                    _slice = _range[i-1..$];
            }
            else {
                _slice = _range[];
            }
        }
    }
}
