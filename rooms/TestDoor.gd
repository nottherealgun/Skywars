extends StaticBody2D

var player_in = false

func _ready():
	for p in Global.active_players:
		p.does_action.connect(open_door)

func open_door(player:Object):
	if player_in:
		player_in = false
		Global.build_stage()

func _on_area_2d_area_entered(area):
	$Sprite.play("forward")
	if area.get_parent().is_in_group("player"):
		player_in = true

func _on_area_2d_area_exited(area):
	$Sprite.play_backwards("forward")
	if area.get_parent().is_in_group("player"):
		player_in = false
