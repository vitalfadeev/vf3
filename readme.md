# Объект

## Уровни

1. Плотный
Видимый (световые точки)

2. Воздушный
Пси (границы)

Правила размещения (опирается на физ.границы)

Данные (по данным меняется вид)


## Pos, Vid, Size

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

## "Childs"

Chidls not childs - is linked

El.childs[] -> el, el, el

El.group[] -> el, el, el
El.linked[] -> el, el, el


## group
el
  group = group_id


## ryad, ryadki


## pos_control


##
no tree, but is are ray
ray + links = tree


## Elements, Groups
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
  

## invalidate on move
When move icon => invalidate his area (pos,size)
icon
  on_move ()
  on_destroy ()
    draw-na.invalidate (pos,size)

## Text is draw operations
"abc"+font => draw_ops[] => [line,line,line,...]
draw_ops[] => draw_id
draw_id => resource
