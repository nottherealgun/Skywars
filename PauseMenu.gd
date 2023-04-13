extends Control

func _process(delta):
	if Input.is_action_just_pressed("pause"):
		visible = !visible
		if visible:
			Engine.time_scale = 0.0
		else:
			Engine.time_scale = 1.0

func _on_button_1_mouse_entered():
	$Button1.scale = Vector2(1.1,1.1)

func _on_button_1_mouse_exited():
	$Button1.scale = Vector2(1,1)

func _on_button_1_pressed():
	hide()
	Engine.time_scale = 1.0

func _on_button_2_mouse_entered():
	$Button2.scale = Vector2(1.1,1.1)

func _on_button_2_mouse_exited():
	$Button2.scale = Vector2(1,1)

func _on_button_2_pressed():
	pass # Replace with function body.

func _on_button_3_mouse_entered():
	$Button3.scale = Vector2(1.1,1.1)

func _on_button_3_mouse_exited():
	$Button3.scale = Vector2(1,1)

func _on_button_3_pressed():
	pass # Replace with function body.

func _on_button_4_mouse_entered():
	$Button4.scale = Vector2(1.1,1.1)

func _on_button_4_mouse_exited():
	$Button4.scale = Vector2(1,1)

func _on_button_4_pressed():
	get_tree().quit()
