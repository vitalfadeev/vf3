struct
Resource {
    Font font;
    Size size;
    ID   index;

    alias Font = void*;
    alias Size = int;
    alias ID   = dchar;
}

//struct
//Resources {
//    Resource[] s;
//    alias s this;

//    alias ID = typeof (s.length);

//    ID
//    open (Resource.Font font, Resource.Size size, Resource.ID index) {
//        s ~= Resource (font,size,index);
//        return resources.length-1;
//    }

//    ID
//    open (ref Resource resource) {
//        s ~= resource;
//        return resources.length-1;
//    }
//}

//alias Font_Resource  = _Resource!Size;
//alias Size_Resource  = _Resource!Char;
//alias Char_Resource  = _Resource!Draws;

//alias Dir_Resource  = _Resource!File;
//alias File_Resource = _Resource!Rec;

struct
_Resource (E) {
    E[]
    read () {
        return [];
    }
}

//alias Dir_Resource  = _Resource!Text_File;
//alias Text_File_Resource = _Resource!(Text_File.Rec);


// Load Resource
//   Resource.id
// Conert Resource 
//   to draws
//
// Draws
//   'A' -> draws
//   char.id -> draws
//   image.id -> draws
//   font + 'A' -> draws
//
// Resource_Set
//   Arial  - set
//   Sans   - set
//   Serif  - set
//
// Resource_Set
//   Arial  - set, with 'A'
//   Sans   - set, with 'A'
//   Serif  - set, with 'A'
//
// Char id = font,size,index
//
// Resource.id = font,size,index
//
// resource_id (font,size,index)
//
// new Resource (font,size,index)
//
// Resource (font,size,index)
// 
// resources.open (font,size,index)
// id = resources.open (font,size,index)
//

// Resources
//   font
//     size
//       index
//
//   font_id = open font 
//   size_id = open size
//   char_id = open index
//
//   font_id = open font   <- dir
//   size_id = open size   <- dir
//   char_id = open index  <- file
//     read draws

//   font              <- dir
//     size            <- dir
//       index         <- file
//         read (draws)

// fd = open (Font ("Arial"))
// fd = open (Font ("Arial"), Size(10))
// fd = open ("Arial/10")
// fd = open ("Arial/10/A")
// fd = open ("Arial", "10", 'A')
// fd = open ("Arial", "10", "A")
// read (fd,draws)

// fd = open ("Arial/10/A")
// fd = open ("Arial", "10", 'A')
// fd = open (Font ("Arial"), Size ("10"), Char ('A'))
// fd = Font.open ("Arial", "10", 'A')
// read (fd,draws)

// fd.read (draws)

// fd = open ("Arial/10/A")
// _buffer_slice = fd.read (buffer)
// fd.close ()

// fd = Resource.open (path)  <- file or dir. read (file) -> [rec]. read (dir) -> [file]
// _buffer_slice = fd.read (buffer)
// fd.close ()

//struct
//Font {
//    alias ID = Font_ID;

//    ID
//    open (string name) {
//        return id;
//    }
//}

//struct
//Font_ID {
//    size_t _super;
//    alias _super this;

//    void
//    read () {
//        // size[]
//    }

//    void
//    close () {
//        //
//    }
//}

//struct
//Size_ID {
//    size_t _super;
//    alias _super this;

//    void
//    read () {
//        // draws[]
//    }

//    void
//    close () {
//        //
//    }
//}
