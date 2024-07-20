import std.socket;
import std.string;
import log : log;
public import std.socket : Socket,SocketShutdown;
 
 
class 
Server_socket_base : Socket {
    string     socket_path;
    Socket[]   connected_clients;
    bool       is_running = true;
    char[1024] buffer;

    this (string socket_path) {
        this.socket_path = socket_path;
        super (AddressFamily.UNIX, SocketType.STREAM);
        this.setOption (SocketOptionLevel.SOCKET, SocketOption.REUSEADDR, true);
        this.bind (new UnixAddress (socket_path));
    }

    void
    go () {
        this.listen (10);
        log ("listening");

        auto read_set = new SocketSet ();

        while (is_running) {
            read_set.reset();
            foreach (client; connected_clients)
                read_set.add (client);
            read_set.add (this);

            //
            auto event_count = Socket.select (read_set, null, null);

            if (event_count != 0 && event_count != -1) {
                // check connected
                foreach (i,client; connected_clients.dup) {
                    if (read_set.isSet (client)) {
                        auto got = client.receive (buffer[]);
                        if (got != 0 && got != Socket.ERROR) {
                            string s_from_client = buffer[0 .. got].idup;
                            log ("q: ", s_from_client);

                            on_data (client,s_from_client.strip);
                        }
                        // errors
                        else
                        if (got == Socket.ERROR) {
                            log ("socket error:");
                            throw new Exception (lastSocketError ());
                        }
                        else
                        if (got == 0) {
                            import std.algorithm.mutation;
                            log ("socket disconnected");
                            client.close();
                            connected_clients = connected_clients.remove (i);
                            on_client_disconnected (client);
                        }
                    }
                }

                // check new
                if (read_set.isSet (this)) {
                    log ("accepting new socket");
                    auto new_socket = this.accept ();
                    //new_socket.send ("Hello!\n");
                    //new_socket.shutdown (SocketShutdown.SEND);
                    connected_clients ~= new_socket;
                    on_client_connected (new_socket);
                }
            }
            // errors
            else
            if (event_count == -1) {
                continue;
            }
            else
            if (event_count == 0) {
                log ("Select timed out.");
                continue;
            }
        }
    }

    void
    finish () {
        is_running = false;
        //shutdown (SocketShutdown.BOTH);
        //release ();
    }

    //
    void
    on_data (Socket client, string s) {
        //
    }

    void
    on_client_disconnected (Socket client) {
        //
    }

    void
    on_client_connected (Socket client) {
        //
    }
}


