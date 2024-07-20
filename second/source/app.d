import std.stdio;
import my_client;
alias log = writeln;

void 
main() {
	import socket_file;

	string pathname = "/tmp/vf.soc";
    auto f = Socket_File.open (pathname);  // File.ID
	log ("f.fd: ",f.fd);
	f.write ("1.mp4\n");
	f.flush ();
	char[] buffer;
	buffer.length = 1000;
	string s;
	foreach (e; f.read (buffer))
		s ~= *e;
	log (s);
	f.close ();
}


void 
main2 (string[] args) {
	if (args.length)
		from_args (args);
	else
		from_stdin ();
}

void
from_args (string[] args) {
	new My_client ("/tmp/vf.soc")
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


// C
//   socket
//   menu
//     echo "menu/done/" | socat - socket
//
// C [items,...] -> stdin -> menu (socket,-) -> stdout -> socat -> socket

// deb
// show deb
// install
