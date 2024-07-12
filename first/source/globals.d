import db : Db;
import mime_database : Mime_database;

struct
Globals {
    static Db             db;
    static Mime_database  mime_db;

    static
    void
    load () {
        db.load ();
        mime_db.load ();
    }
}
