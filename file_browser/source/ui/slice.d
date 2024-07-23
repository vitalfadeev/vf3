import std.stdio : writeln;
import std.range : ElementType;
import std.algorithm.searching : countUntil;
alias log = writeln;

struct
Slice (R) {
    R _range;
    S _slice;

    alias E = ElementType!R;
    alias S = typeof (R[]);

    size_t selected;

    void
    _on_key_down () {
        if (selected == _slice.length-1) {
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
        else
            selected++;
    }

    void
    _on_key_up () {
        if (selected == 0) {
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
        else
            selected--;
    }
}
