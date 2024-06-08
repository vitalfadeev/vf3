import color;
import pos;

struct
Image {
    Image_rec[] recs;
}

struct
Image_rec {
    Color color;
    Pos[] pos;
}
