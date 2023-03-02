extends Node
# Level Manager

@onready var map = Global.Map

func _ready():
	var size = Vector2i(20,20)
	for i in size.x:
		for j in size.y:
			map.set_cell(0,Vector2(i,j),0,Vector2i(32+randi()%3,1))
