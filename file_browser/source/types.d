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
}

alias X=int;
alias Y=int;
