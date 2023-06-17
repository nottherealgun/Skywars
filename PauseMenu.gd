extends Control

var tween : Tween

func _process(delta):
	if !Global.transitioning and !get_node("/root/Main/GUI/MainMenu").visible:
		if Input.is_action_just_pressed("pause"):
			visible = !visible
			if visible:
				get_tree().paused = true
			else:
				get_tree().paused = false

func _on_button_1_mouse_entered():
	tween = create_tween().set_trans(Tween.TRANS_CUBIC)
	tween.tween_property($Button1,"scale",Vector2(1.1,1.1),0.1)
	
func _on_button_1_mouse_exited():
	tween = create_tween().set_trans(Tween.TRANS_CUBIC)
	tween.tween_property($Button1,"scale",Vector2(1,1),0.1)
	
func _on_button_1_pressed():
	hide()
	get_tree().paused = false

func _on_button_2_mouse_entered():
	tween = create_tween().set_trans(Tween.TRANS_CUBIC)
	tween.tween_property($Button2,"scale",Vector2(1.1,1.1),0.1)

func _on_button_2_mouse_exited():

	tween = create_tween().set_trans(Tween.TRANS_CUBIC)
	tween.tween_property($Button2,"scale",Vector2(1,1),0.1)

func _on_button_2_pressed():
	$"../SettingsMenu".show()
	
func _on_button_3_mouse_entered():
	tween = create_tween().set_trans(Tween.TRANS_CUBIC)
	tween.tween_property($Button3,"scale",Vector2(1.1,1.1),0.1)

func _on_button_3_mouse_exited():
	tween = create_tween().set_trans(Tween.TRANS_CUBIC)
	tween.tween_property($Button3,"scale",Vector2(1,1),0.1)

func _on_button_3_pressed():
	GameManager.money = 0
	Global.music_play("lobby")
	get_tree().paused = false
	Global.generic_transition()
	await Global.built_level
	hide()
	$"../MainMenu".show()
	LevelManager.clear_level()
	for p in Global.active_players:
		Global.active_players.erase(p)
		p.queue_free()

	Global.Inventory.clean_player_slots()

func _on_button_4_mouse_entered():
	tween = create_tween().set_trans(Tween.TRANS_CUBIC)
	tween.tween_property($Button4,"scale",Vector2(1.1,1.1),0.1)

func _on_button_4_mouse_exited():
	tween = create_tween().set_trans(Tween.TRANS_CUBIC)
	tween.tween_property($Button4,"scale",Vector2(1,1),0.1)

func _on_button_4_pressed():
	get_tree().quit()
