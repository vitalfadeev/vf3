import std.stdio;
import s;
import bus;

void main()
{
	//
	//S s1;
	//s1.query ("/home/vf/Videos/girls.mp4");

	//
	new My_server ("/tmp/vf_bus.soc")
	    .go ();
}

// hotkeys/
//   ctrl-c -> copy_to_clipboard
//   ctrl-alt-t -> terminal

// Event // from menu 
//  id_of_query
//  done
//  selected_item

// 1.mp4
// query_id = new_query_id // for client "1" for query "1.mp4"
// query_registry
//   query_id,client_socket,question
// menu (query_id,items)

// menu
//   done
//     send_event (menu,done,quesy_id,selected_item)

// socket -> 1.mp4
// events -> Event (menu,done,qid,item)

// socket <- 1.mp4
// socket <- event:menu,done,qid,item

// echo "event:menu,done,quesy_id,selected_item" | socat /tmp/vf.soc
// VF_QUERY_ID
// VF_QUERY_STRING
