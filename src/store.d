//struct
//Store {
//    Data_ptr
//    get (Data_id id) {
//        // load from file, from hard storage
//        // return address in memory
//        Data_ptr data_ptr;
//        return data_ptr;
//    }

//    void
//    put () {
//        //
//    }
//}

alias Data_id = byte;

struct
Data {
    MemoryRay mray;
}

alias Data_ptr = Data*;


struct 
Memory {
    MemoryRay[] ray;
}

struct 
MemoryRay {
    size_t size;
    void*  ptr;
}


struct
Store (T) {
    T[] s;

    void
    put (I)(I i, T a) {
        s[i] = a;
    }

    T
    get (I) (I i) {
        return s[i];
    }
}
