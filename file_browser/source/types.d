//module types;

struct
Pos {
   X x;
   Y y; 
}

struct
Size {
    X w;
    Y h; 

    void
    opOpAssign (string op : "+") (Size b) {
        this.w += b.w;
        this.h += b.h;
    }

    Size
    opBinary (string op : "+") (Pad b) {
        return 
            Size (
                this.w + b.l + b.r, 
                this.h + b.t + b.b
            );
    }
}

struct 
Pad {
    int t;
    int r;
    int b;
    int l;
}

alias X=int;
alias Y=int;
