extends Area2D

@onready var holder = get_parent()
var held_by_player = false

func _ready():
	holder.tree_exiting.connect(drop)
	Global.active_entities.append(self)

func _process(delta):
	if !held_by_player and is_instance_valid(holder) and holder.is_in_group("player"):
		if !is_instance_valid(holder.key):
			position += position.direction_to(holder.position)*100*delta
			if position.distance_to(holder.position) < 50:
				held_by_player = true
				get_parent().remove_child(self)
				holder.add_child(self)
				holder.key = self
				position = Vector2.ZERO
				var t = create_tween()
				t.tween_property(self,"position",Vector2(0,-60),0.25)

func drop():
	show()
	monitoring = true
	var pos = holder.position
	get_parent().remove_child(self)
	Global.Main.add_child.call_deferred(self)
	position = pos
	if holder.is_connected("tree_exiting",drop):
		holder.disconnect("tree_exiting",drop)

func _on_area_entered(area):
	var entity = area.get_parent()
	if entity.is_in_group("player"):
		holder = entity
