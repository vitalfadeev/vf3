import std.socket;

struct
Query_registry {
    Query_id _last_query_id;
    Query_registry_rec[] s;

    Query_id
    new_query_id () {
        do {
            _last_query_id++;
        } while (query_id_in_use (_last_query_id));

        return _last_query_id;
    }

    bool
    query_id_in_use (Query_id query_id) {
        foreach (ref rec; s)
            if (rec.query_id == query_id)
                return true;
        return false;
    }

    Query_id
    add (string query, Socket client) {
        auto query_id = new_query_id;
        s ~= Query_registry_rec (query_id,query,client);
        return query_id;
    }

    void
    remove (Socket client) {
        import std.algorithm.mutation;

        foreach (size_t i,ref rec; s)
            if (rec.client == client) {
                s = s.remove (i);
                break;
            }
    }

    void
    remove (Query_id query_id) {
        import std.algorithm.mutation;

        foreach (size_t i,ref rec; s)
            if (rec.query_id == query_id) {
                s = s.remove (i);
                break;
            }
    }

    bool
    get (Query_id query_id, ref Query_registry_rec result) {
        foreach (ref rec; s)
            if (rec.query_id == query_id) {
                result = rec;
                return true;
            }

        return false;
    }

    void
    save_s (C) (C client, string query) {
        foreach (ref rec; s)
            if (rec.client == client) {
                rec.query = query;
                break;
            }
    }
}


struct
Query_registry_rec {
    // using in event
    //   menu,done,quesy_id,selected_item
    Query_id query_id;
    string   query;
    Socket   client;
}

struct
Query_id {
    size_t _a;
    alias _a this;
}
