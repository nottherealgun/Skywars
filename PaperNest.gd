extends Enemy

func _on_player_detect_area_entered(area):
	super(area)
	var entity = area.get_parent()

func _on_timer_timeout():
	if target:
		for i in 3:
			if !get_parent() or !target:
				continue
			$AnimationPlayer.play("summon")
			var paper = Global.call_deferred("spawn_enemy","corrupted_paper",position+get_parent().position+position.direction_to(target.position)*50)
			Global.active_entities.append(paper)
			var new_arr = Global.current_map[1].get_meta("entities")
			new_arr.append(paper)
			Global.current_map[1].set_meta("entities",new_arr)
			await get_tree().create_timer(0.2).timeout
