module cache;

auto 
cache (R) (R range, Cache_id cache_id) {
    import std.range : ElementType;

    struct
    _cache {
        R        range;
        Cache_id cache_id;
        int      w;
        int      h;
        static E[][Cache_id] _cache;

        alias E = ElementType!R;
        alias DG = int delegate (E e);

        E front () { return E ();};

        int 
        opApply (scope DG dg) {
            auto cached = cache_id in _cache;
            if (cached !is null) 
            {  // cached
                foreach (e; *cached) {
                    int result = dg (e);
                    if (result)
                        return result;
                }
                return 0;
            }
            else 
            {  // non-cached
                _cache[cache_id] = [];
                auto es = cache_id in _cache;
                foreach (e; range) {
                    *es ~= e;  // to cache
                    int result = dg (e);
                    if (result)
                        return result;
                }
            }

            return 0;
        }    
    }

    return _cache (range,cache_id,range.w,range.h);
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

