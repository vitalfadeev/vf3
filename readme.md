# Объект

## Уровни

1. Плотный
Видимый (световые точки)

2. Воздушный
Пси (границы)

Правила размещения (опирается на физ.границы)

Данные (по данным меняется вид)


## Pos, Vid, Size
```
no "pos" in element, but pos in struct around element

psy.Pos -> struct pos

vis.get -> vector comands -> pixmap

psy.size.get -> struct size

Cont {one pos}

struct
ContEl {
    pos
    el
}
```

## "Childs"

```
Chidls not childs - is linked

El.childs[] -> el, el, el

El.group[] -> el, el, el
El.linked[] -> el, el, el
```


## group
el
  group = group_id


## ryad, ryadki


## pos_control


##
```
no tree, but is are ray
ray + links = tree
```


## Elements, Groups
```
Groups   Elements
------   --------
Group1 - Element1
       - Element2
       - Element3 

Group2 - Element4
       - Element5
       - Element6 

foreach (group; groups)
  group.go ()
    foreach (e; group.es)
      cb (e);    
```


## invalidate on move
```
When move icon => invalidate his area (pos,size)
icon
  on_move ()
  on_destroy ()
    draw-na.invalidate (pos,size)

## Text is draw operations
"abc"+font => draw_ops[] => [line,line,line,...]
draw_ops[] => draw_id
draw_id => resource
```

# SVGA Video Memory Manager
VRAM - app1
     - app2

app <- event
draw
  VRAM_ptr
  size w,h

# OpenGL video-card sharing
shared memory for draws[draw_id]
access via lib

                                       X
       lib              shred memory   writer
app1 - .write (draws) - ...          - 
app2 -
                                     - .read (draws) - video-card
                                                       (draws-to-card_registers)

open,write,read,close 
seek
seek_read
seek_write

select  - for monitor file I/O operations 

## events
app <- event
draw
  draw_store_ptr  .put
  size w,h
  is_full_screen

## request
request (size)
request (full_screen)

## X

X
app_window
  on-click 
    app-activate
      send-to-app event draw (size)

app
  on-event
    case draw:
      ...

global event line | shared memory
   app event line |

global - shared memory - app

# open
*.mp4 open mpv

## links
mp4 - open - mpv

## config
what       what
      link
----- ---- ----
*.mp4 open mpv

what       what
  link   link
      what
----- ---- ----
*.mp4 open mpv

*.mp4 - open - mpv

mpv.ini
[open]
*.mp4

query
  *.mp4 ? mpv -> open
  mpv ? -> open
  mpv open ? -> mp4

## click in file manager
file.mp4 ? -> open
  file.mp4 open -> mpv


## deb
deb GUI

##
app - package - menu
mpv - mov
*.mp4 - menu - open - mpv - mpv open *.mp4

#
Any_object open Any_object
a open b
b.open (Any_object a)

service.open ()
  return result

service.event (e)
  events ~= result (e)

events via linux.sockets

# object identify
* - any
*.mp4 - file .mp4

menu (object_type)
  open

menu (file)
  open
  delete
  copy

menu (folder)
  open
  delete
  copy

[file]
open
delete
copy

[folder]
open
delete
copy

~/config/menu/file
[file]
custom
-delete

enum
Object_type {
    file   = "file",
    folder = "folder",
}

## menu for type
get_menu_for_type (Object_type type)
  open
  delete
  copy

object
  type
  get_menu ()
    open
    delete
    copy

get_menu_for_type (Object_type type)
  service1.open
  service1.delete
  service1.copy
  service2.custom

service1
  event
    case open:   _open (this,src,open,object)
    case delete: _delete (this,src,delete,object)
    case copy:   _copy (this,src,copy,object)

service2
  event
    case custom:

mpv
  open *.mp4  -> service_mpv.open ("file_name.mp4")

service_mpv
  this:
    mpv --input-ipc-server=/tmp/mpv-socket
    mpv --input-ipc-client=fd://123
  ~this:
    killall mpv
  open:
    echo "..." | socat /tmp/mpv-socket
    activate window
  menu:
    open *.mp4
    open 
      *.avi
      *.mpg
      *.mp2
      *.mp3
      *.mkv
    open *.mp4 // icon open.png

service_trash
  this:
    trash --input-ipc-server=/tmp/trash-socket
  ~this:
    killall trash
  delete:
    echo "..." | socat /tmp/trash-socket
  status:
    return "{99%, 9/10 files}"

custom
  menu:
    open *.txt
  open:
    xterm -e mcedit $URL

service_downloader
  this:
    downloader
  ~this:
    killall downloader
  download:
    curl $URL $FILE
  menu:
    download ^http://*
    download ^https://*
  on download:
    download
    send download $URL $FILE

service_cam
  this:
    cam
  ~this:
    killall cam
  take_photo:
    echo "..." | socat /tmp/cam-socket
    event cam_photo $PHOTO_URL
  menu:
    take_photo

service_:
  get photo:
    // internal function
  on get photo:
    // event listener
wanter_:
  this:
    get photo
      .done:
        copy $FILE
  on get photo done:
    copy $FILE

service_chat
  on key:
    get photo
      .done: copy $FILE photo.png  <--
  on key:
    get photo
      on get photo done: copy $FILE photo.png
  on key:
    get photo
      on done: copy $FILE photo.png
  on key:
    get photo
      copy $FILE photo.png

service_cam2
  on get photo:
    ...take photo && save to $PHOTO_URL...
    say get photo done $PHOTO_URL

service_:
  cam.photo:
    // listen for public event "cam.photo"
    // job
    //   send "cam.photo.done"
    //   send "cam.photo.fail"
  *.cam.photo:
    // listen for public event "cam.photo"
    // job
    //   send "*.cam.photo.done"
wanter_:
  this:
    cam.photo  // push event "wanter_.cam.photo" in public
      .done:   // wait event "wanter_.cam.photo.done" in public
        copy $FILE
      .fail:   // wait event "wanter_.cam.photo.fail" in public
        notify "Cam photo fail"
  *.cam.photo.done:  // wait event "*.cam.photo.done" in public
    copy $FILE

// menu
service_mpv:
  menu:
    file.*.mp4:
      service_mpv.open_file $URL
    folder.*:
      service_mpv.open_folder $URL

// do or menu
service_mpv:
  file.*.mp4:
    // open. open file and play
    service_mpv.open_file $URL
  folder.*:
    // open. open file and play
    service_mpv.open_folder $URL
  folder.*:
    // short. detailed description
    // menu. menu gray text
    // auto-comment
    // icon: open.png
    service_mpv.open_folder $URL
wanter_:
  what can on "file.*.mp4":
    service_mpv:  file.*.mp4: service_mpv.open_file $URL
    service_file: file.*: service_file.copy_file $URL
    service_file: file.*: service_file.delete_file $URL
  what can on "file.*.mp4":
    service_mpv:    file.*.mp4: service_mpv.open_file $URL
    service_copy:   file.*: service_copy $URL
    service_delete: file.*: service_delete $URL

alternatives:
  *.mp4:
    // alter-menu. alter-desc
    // icon: alter-icon.png

?

? -> menu

*.mp4 ? -> menu

file.mp4 [key ?] -> menu

# realizzatin
string s; // like a: "file:///*.mp4"
s.menu ();
s.emit_public_event ()

public_queue.listen ()
  switch (event.s)
  case "*.mp4": 
    {}
  if (regex.match (s, "*.mp4")) 
    {}

config files
  events regexes
    actions

service_gui
  this:
    video_card // dev_id,kernel_module
      connected.monitor 
        resolution  // set maximal

gui_desktop.cfg
service_gui_desktop
  desktop:
    gui
      //video_card // dev_id,kernel_module
      //  connected.monitor 
      //    resolution  // set maximal
    wallpaper
      open, read
      scale to resolution
      to video_card

service_  // os.init
  this:
    desktop

service_  // os.init
  this:
    gui.desktop
      .fail:
        text.desktop
      .done:
        wait event


# Event

key.a
a.key

"a.key" -> "a","key" -> 0.0.1.1

a.b.c.d
4 Bytes
32 bites

## "custom" to evdev
"custom.event" -> evdev
select (evdev.socket) -> event

struct 
input_event {
    timeval time;
    ushort  type;
    ushort  code;
    uint    value;
};

## type
EV_SYN
EV_KEY
EV_REL
EV_ABS
EV_MSC
EV_SW
EV_LED
EV_SND
EV_REP
EV_FF
EV_PWR
EV_FF_STATUS

## type / code
EV_SYN
  SYN_REPORT
  SYN_CONFIG
  SYN_MT_REPORT
  SYN_DROPPED
EV_KEY
  BTN_TOOL_<name>
  BTN_TOUCH
  BTN_TOOL_FINGER
  BTN_TOOL_DOUBLETAP
  BTN_TOOL_TRIPLETAP
  BTN_TOOL_QUADTAP
EV_REL
  REL_WHEEL
  REL_HWHEEL
  REL_WHEEL_HI_RES
  REL_HWHEEL_HI_RES
EV_ABS
  ABS_DISTANCE
  ABS_PROFILE
  ABS_MT_<name>
  ABS_PRESSURE
  ABS_MT_PRESSURE
EV_MSC
  MSC_TIMESTAMP
EV_SW
  SW_LID
EV_LED
EV_SND
EV_REP
EV_FF
EV_PWR
EV_FF_STATUS

## custom
device.write (e.EV_KEY, e.BTN_TOUCH, 1)
uinput
libevdev

```C
#include <linux/uinput.h>

void 
emit (int fd, int type, int code, int val) {
   struct input_event ie;

   ie.type = type;
   ie.code = code;
   ie.value = val;
   /* timestamp values below are ignored */
   ie.time.tv_sec = 0;
   ie.time.tv_usec = 0;

   write (fd, &ie, sizeof(ie));
}
```
## userio

struct 
userio_cmd {
    __u8 type;
    __u8 data;
};

userio
  USERIO_CMD_REGISTER
  USERIO_CMD_SET_PORT_TYPE
  USERIO_CMD_SEND_INTERRUPT

## custom linux input driver

