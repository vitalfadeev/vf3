import std.array;
import mime.database;
import mime.paths;

struct
Mime_database {
    MimeDatabase database;

    void
    load () {
        auto mime_paths = mime.paths.mimePaths.array;
        database = new MimeDatabase (mime_paths);
    }

    auto
    mime_type_for_file_name (string file_anme) {
        return database.mimeTypeForFile (file_anme, MimeDatabase.Match.globPatterns);
    }
}
