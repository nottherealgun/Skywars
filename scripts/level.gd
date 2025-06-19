class_name Level extends Node2D

@export var map : TileMapLayer
var entities : Array[Node] = []

func _ready() -> void:
	print("Loaded map: "+name)
	if has_meta("boss"):
		var center : Vector2i = map.get_used_rect().get_center()
		var new_boss = GameManager.spawn_boss("printerovski_3000",Vector2(center*64))
		entities.append(new_boss)
		new_boss.position += position
		GameManager.boss_encounter(new_boss)
