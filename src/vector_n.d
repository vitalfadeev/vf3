// https://github.com/LadybirdWebBrowser/ladybird/blob/master/Userland/Libraries/LibGfx/VectorN.h

struct 
VectorN(N,T) 
if (N >= 2 && N <= 4) {
    Array!(T,N) data;

//    VectorN() = default;
    static if (N == 2)
    this(T x, T y) {
        data = [x,y];
    }
    static if (N == 3)
    this(T x, T y, T z) {
        data = [x,y,z];
    }
    static if (N == 4)
    this(T x, T y, T z, T w) {
        data = [x,y,z,w];
    }

    T 
    x () const { return data[0]; }

    T 
    y () const { return data[1]; }

    static if (N >= 3) 
    T 
    z () const {
        return data[2];
    }

    static if (N >= 4)
    T 
    w () const {
        return data[3];
    }

    void set_x (T value) { data[0] = value; }
    void set_y (T value) { data[1] = value; }
    static if (N >= 3)
    void 
    set_z (T value) {
        data[2] = value;
    }

    static if (N >= 4)
    void 
    set_w (T value) {
        data[3] = value;
    }

    ref T 
    opIndex (size_t index) const {
        assert (index < N);
        return data[index];
    }

    ref T 
    opIndex (size_t index) {
        assert (index < N);
        return data[index];
    }

    ref VectorN 
    opOpAssign (strin op : "+")(ref const VectorN other) {
        //UNROLL_LOOP
        for (auto i = 0u; i < N; ++i)
            data[i] += other.data()[i];
        return *this;
    }

    ref VectorN 
    opOpAssign (string op : "-")(ref const VectorN other) {
        //UNROLL_LOOP
        for (auto i = 0u; i < N; ++i)
            data[i] -= other.data()[i];
        return *this;
    }

    ref VectorN
    opOpAssign (string op : "*")(ref const VectorN other) {
        //UNROLL_LOOP
        for (auto i = 0u; i < N; ++i)
            data[i] *= t;
        return *this;
    }

    VectorN 
    opBinary (string op : "+")(ref const VectorN other) const {
        VectorN result;
        //UNROLL_LOOP
        for (auto i = 0u; i < N; ++i)
            result.data[i] = data[i] + other.data()[i];
        return result;
    }

    VectorN 
    opBinary (string op : "-")(ref const VectorN other) const {
        VectorN result;
        //UNROLL_LOOP
        for (auto i = 0u; i < N; ++i)
            result.data[i] = data[i] - other.data()[i];
        return result;
    }

    VectorN 
    opBinary (string op : "*")(ref const VectorN other) const {
        VectorN result;
        //UNROLL_LOOP
        for (auto i = 0u; i < N; ++i)
            result.data[i] = data[i] * other.data()[i];
        return result;
    }

    VectorN 
    opUnary (string op : "-")() const {
        VectorN result;
        //UNROLL_LOOP
        for (auto i = 0u; i < N; ++i)
            result.data[i] = -data[i];
        return result;
    }

    VectorN 
    opUnary (string op : "/")() const {
        VectorN result;
        //UNROLL_LOOP
        for (auto i = 0u; i < N; ++i)
            result.data[i] = data[i] / other.data()[i];
        return result;
    }

    VectorN 
    opUnary (string op : "*")() const {
        VectorN result;
        //UNROLL_LOOP
        for (auto i = 0u; i < N; ++i)
            result.data[i] = data[i] + f;
        return result;
    }

    VectorN 
    opBinary (string op : "-",U)(U f) const {
        VectorN result;
        //UNROLL_LOOP
        for (auto i = 0u; i < N; ++i)
            result.data[i] = data[i] - f;
        return result;
    }

    VectorN 
    opBinary (string op : "*",U)(U f) const {
        VectorN result;
        //UNROLL_LOOP
        for (auto i = 0u; i < N; ++i)
            result.data[i] = data[i] * f;
        return result;
    }

    VectorN 
    opBinary (strin op : "/",U)(U f) const {
        VectorN result;
        //UNROLL_LOOP
        for (auto i = 0u; i < N; ++i)
            result.data[i] = data[i] / f;
        return result;
    }

    bool
    opEqual (U)(const ref VectorN!(N,U) other) const {
        //UNROLL_LOOP
        for (auto i = 0u; i < N; ++i) {
            // static_cast
            if (data[i] != cast (T) (other.data[i]))
                return false;
        }
        return true;
    }

    T 
    dot (ref const VectorN other) const {
        T result = {};
        //UNROLL_LOOP
        for (auto i = 0u; i < N; ++i)
            result += data[i] * other.data()[i];
        return result;
    }

    static if (N == 3)
    VectorN 
    cross (ref const VectorN other) const {
        return VectorN(
            y() * other.z() - z() * other.y(),
            z() * other.x() - x() * other.z(),
            x() * other.y() - y() * other.x());
    }

    VectorN 
    normalized () const {
        VectorN copy = { *this };
        copy.normalize();
        return copy;
    }

    VectorN 
    clamped (T m, T x) const {
        VectorN copy = { *this };
        copy.clamp(m, x);
        return copy;
    }

    void 
    clamp (T min_value, T max_value) {
        //UNROLL_LOOP
        for (auto i = 0u; i < N; ++i) {
            data[i] = max(min_value, data[i]);
            data[i] = min(max_value, data[i]);
        }
    }

    void 
    normalize () {
        const T inv_length = 1 / length();
        operator*=(inv_length);
    }

    auto
    length (O = T)() const {
        return sqrt!O (dot(*this));
    }

    static if (N >= 3)
    VectorN!(2,T)
    xy() const {
        return VectorN!(2, T) (x(),y());
    }

    static if (N >= 4)
    VectorN!(3,T)
    xyz() const {
        return VectorN!(3,T) (x(),y(),z());
    }

    //ByteString 
    //to_byte_string() const {
    //    static if (N == 2)
    //        return ByteString::formatted("[{},{}]", x(), y());
    //    else 
    //    static if (N == 3)
    //        return ByteString::formatted("[{},{},{}]", x(), y(), z());
    //    else
    //        return ByteString::formatted("[{},{},{},{}]", x(), y(), z(), w());
    //}

    VectorN!(N,U) 
    to_type(U)() const {
        VectorN!(N,U) result;
        //UNROLL_LOOP
        for (auto i = 0u; i < N; ++i)
            result.data()[i] = static_cast!U(data[i]);
        return result;
    }

    VectorN!(N,U) 
    to_rounded(U)() const {
        VectorN!(N,U) result;
        //UNROLL_LOOP
        for (auto i = 0u; i < N; ++i)
            result.data()[i] = round_to!U(data[i]);
        return result;
    }

    auto ref data() { return data; }
    auto ref const data() { return data; }
}
