module cache;

import std.stdio : writeln;
alias log = writeln;

auto 
cache (R) (R range, Cache_id cache_id) {
    import std.range : ElementType;

    struct
    _cache {
        R          range;
        Cache_id   cache_id;
        static _Cached[Cache_id] _cache;

        alias E = ElementType!R;
        alias DG = int delegate (E e);

        struct
        _Cached {
            E[] s;
        }

        E front () { return E ();};

        int 
        opApply (scope DG dg) {
            auto _cached = cache_id in _cache;
            if (_cached !is null) 
            {  // cached
                //log ("cached");
                foreach (e; _cached.s) {
                    int result = dg (e);
                    if (result)
                        return result;
                }
                return 0;
            }
            else 
            {  // non-cached
                //log ("non-cached");
                _cache[cache_id] = _Cached ();
                _cached = cache_id in _cache;
                foreach (e; range) {
                    _cached.s ~= e;  // to cache
                    int result = dg (e);
                    if (result)
                        return result;
                }
            }

            return 0;
        }    
    }

    return _cache (range,cache_id);
}

struct
Cache_id {
    size_t _super;
    //alias _super this;

    this (string font_pathname, int font_size, char c) {
        this._super = c;
    }

    size_t 
    toHash () const @safe pure nothrow {
        return _super;
    }

    bool 
    opEquals (ref const Cache_id b) const @safe pure nothrow {
        return this._super == b._super;
    }
}

