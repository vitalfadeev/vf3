void
walk_recursive (string cb_name, E)(ref E start) {
    if (mixin ("start." ~ cb_name ~ " !is null"))
        mixin ("start." ~ cb_name ~ "(start);");
}

