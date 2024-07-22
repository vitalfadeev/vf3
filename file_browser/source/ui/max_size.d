module ui.max_size;

import types;

Size
max_size (Size[] sizes) {
    Size max_size;

    foreach (size; sizes) {
        if (max_size.w < size.w)
            max_size.w = size.w;
        if (max_size.h < size.h)
            max_size.h = size.h;
    }

    return max_size;
}
