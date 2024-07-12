import server_socket_base;
import log : log;


class 
My_menu_server : Server_socket_base {
    alias DONE_DG = void delegate (string s);    

    DONE_DG done_cb;

    this (string socket_path) {
        super (socket_path);
    }

    //
    override
    void
    on_data (Socket client, string s) {
        log ("data: ", s);
        if (done_cb !is null)
            done_cb (s);
        finish ();
    }

    override
    void
    on_client_connected (Socket client) {
        //
    }

    override
    void
    on_client_disconnected (Socket client) {
        //
    }
}
