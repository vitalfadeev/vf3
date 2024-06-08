struct
V_group (E) {
    V_group_es!E es;

    bool
    cond (E* e) {
        return true;
    }
}

struct
V_group_es (E) {
    int 
    opApply (int delegate (E*) dg) {
        // 1. find
        foreach (ref e; global_es)
            if (cond (e))
                local_es ~= e;

        return result;
    }


    void
    opOpAssign (string op : "~") (E* b) {
        _super ~= b;
        //b.groups ~= this;
    }
}
