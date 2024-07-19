import std.stdio;
import dir.dir : Dir, linux_dirent;

void 
main () {
	import std.stdio : printf, writeln, writefln, writef;
	import std.string : fromStringz;

	auto ds = Dir ("/");
	ds.load ();
	ds.sort ();

	foreach (linux_dirent* d; ds) {
	    writef ("%8x ", d.d_ino);
	    writef ("%-7s ", d.d_type);

	    writef ("%s", d.d_name.fromStringz);
	    writeln ();        
	}
}
