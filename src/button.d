import el;
import group;

struct
Button (E) {
    alias T = typeof (this);
    E e;
    alias e this;
}

struct
Icon_button (E) {
    alias T = typeof (this);
    E e;
    alias e this;

    // group
    // group: this, icon, text
}

void
main_test () {
    ES es;

    es ~= cast (E*) new Button!E ();

    es ~= cast (E*) new Icon_button!E ();

    es ~= cast (E*) Icon_button_!E ();
}

auto 
Icon_button_ (E) () {
    //
    auto group_2     = new Group!E ();
    auto btn         = new Button!E (E ()); // z = 0
    //group_2.es ~= cast (E*) btn;
    //group_2.es ~= cast (E*) new Icon!E (E ([group_2]));   // z = 1
    //group_2.es ~= cast (E*) new Text!E (E ([group_2]));   // z = 1
    return btn;
    //
version (_) {
    auto group_id = new_group ();
    ES es;
    es ~= Button!E (E (group_id)); // z = 0
    es ~= Icon!E (E (group_id));   // z = 1
    es ~= Text!E (E (group_id));   // z = 1
    // redirect events from Icon to Button (group_leader)
    // redirect events from Text to Button
    // group in Layer 0
    // event in Layer 0
    // in Layer 0 no collision
    // pos controller attached to group
    // input in layer 0
    // group: [Button_group_leader,Icon,Text]
    // Eample:
    // group = 4
    //   click on Icon (group 4) => click on Groups[4][group_leader]
    return es;

    //
    // Group is E
    // Group: [Group,Button,Icon,Text]
    }
}

auto 
new_group () {
    static Group_id i;
    i++;
    return i;
}


struct
Icon (E) {
    alias T = typeof (this);
    E e;
    alias e this;
}

struct
Text (E) {
    alias T = typeof (this);
    E e;
    alias e this;
}

