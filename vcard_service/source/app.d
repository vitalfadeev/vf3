import std.stdio;


struct
Draws {
    Draw[] s;
}

struct
Draw {
    Color color;
    Pos[] pos;
}

struct
Draw_id {
    size_t draw_id;
}

struct
Draw_store {
    Draws[Draw_id] s;
}


SharedMemory shm;
shm.resize (1024*1024);
auto _draw_store = NamedCondition ("Draw_store", CreateMode.create_only, 1024*1024);
Draw_store* draw_store = cast (Draw_store*) _draw_store.base;
// Shared memory is the fastest interprocess communication mechanism. 
// https://www.boost.org/doc/libs/master/doc/html/interprocess/sharedmemorybetweenprocesses.html#interprocess.sharedmemorybetweenprocesses.sharedmemory
// 1. mmap a shared file
// 2. shm_open, ftruncate, mmap, memcpy, write, (sem_init, sem_wait, sem_post), shm_unlink

void 
main() {
	writeln("Edit source/app.d to start your project.");
}


void
_1 () {
	// GPE (Graphocs Processing Engine)
    // vertex buffer
    // command stream
    //   from MI function
    //   4-bit per function ID: 0x0..0xF

    // PIPELINE_SELECT - select pipeline: 3D or Media
    //   PIPELINE_SELECT 3D

    // MI_FLUSH
    // PIPELINE_SELECT

    // Before issuing a 3DPRIMITIVE command, all state (with the exception of MEDIA_STATE_POINTERS)
	// needs to be valid. 

	// 5.2 Command Map
	//

	// 6. Register Address Maps
	//    MMIO_INDEX 
	//    MMIO_DATA I/O registers.

	// - Выставить видеорежим 1366 x 768
	//   and colot depth 8 bpp
	//     GFX_MODE: 
	//       MMIO: 0/2/0
	//       Default Value: 0x00000800
	//       Size (in bits): 32
	//       Address: 0229Ch
	//
	// - Загрузить xy линии
	// - Заполнить поток команд
	// - Установить указатель на поток команд
	// - Выполнить 3D команду
	//
	// Вставить из буффера обмена
}


struct
Vertex_buffer {
	//
}

struct
Command_stream {
    //
}

struct
URB {  // Unified Return Buffer (URB_FENCE)
    //
}

struct
CURBE {  // Constant URB Entries
    //
}

//
void
GPU_command (
	/* Instruction Type 	 */ int type, 
	/* 3D Instruction Opcode */ int opcode,
	/* pipeline 			 */ int pipeline) {
	type = 0x3;  				// Instruction Type = GFXPIPE = 3h
	opcode = PIPELINE_SELECT;  	// 3D Instruction Opcode 
	// GFXPIPE[28:27 = 1h, 26:24 = 1h, 23:16 = 04h] (Single DW, Non-pipelined)
	return M32 = (type << 29) | (opcode << 16) | (pipeline);
}

alias M32 = uint;
