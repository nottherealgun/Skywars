extends Enemy

#func _process(delta):
#	$Dev.text = str(get_parent().name)

func _on_player_detect_area_entered(area):
	super(area)
	var entity = area.get_parent()
#	if entity.is_in_group("player"):
#		_on_timer_timeout()

func _on_timer_timeout():
	if target:
		for i in 3:
			$AnimationPlayer.play("summon")
			var paper = Global.call_deferred("spawn_enemy","corrupted_paper",position+get_parent().position+position.direction_to(target.position)*50)
			await get_tree().create_timer(0.2).timeout
