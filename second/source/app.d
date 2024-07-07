import std.stdio;
import my_client;
alias log = writeln;


void 
main (string[] args) {
	//from_stdin ();
	from_args (args);
}

void
from_args (string[] args) {
	new My_client ("/tmp/vf_bus.soc")
		.go (args[1..$]);
}

void
from_stdin () {
	import std.range;
	import std.array;
	import std.string;
	import std.conv;

	string[] lines = stdin.byLine.array.join ("").to!string.split ("\n");

	new My_client ("/tmp/vf_bus.soc")
		.go (lines);
}


