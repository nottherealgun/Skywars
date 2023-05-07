extends Control

@export var skip_splashscreen = false
@onready var testmap = load("res://rooms/"+Global.rooms[0].file).instantiate()

func _ready():
	$PlayButton.pressed.connect(button_pressed.bind("play"))
	$OptionsButton.pressed.connect(button_pressed.bind("options"))
	$CreditsButton.pressed.connect(button_pressed.bind("credits"))
	$QuitButton.pressed.connect(button_pressed.bind("quit"))
	$Options/Back.pressed.connect(button_pressed.bind("options_back"))
	$Credits/Back.pressed.connect(button_pressed.bind("credits_back"))
	
	$"../Splashscreen/AnimationPlayer".play("splashscreen")
	if skip_splashscreen:
		$"../Splashscreen/AnimationPlayer".seek(8.5)

func _input(event):
	if Input.is_key_pressed(KEY_SPACE):
#		$"../Splashscreen/AnimationPlayer".play("splashscreen")
		pass

func button_pressed(button:String):
	$AudioStreamPlayer.play()
	match button:
		"play":
			hide()
			$CanvasLayer.hide()
			var new_player = load("res://players/player.tscn").instantiate()
			Global.Main.add_child(new_player)
			GameManager._game_start()
			Global.sync_room(testmap)

		"options":
			$AnimationPlayer.play("options")
		"credits":
			$AnimationPlayer.play("credits")
			$Credits.reset_autoscroll()
		"quit":
			get_tree().quit()
		
		"options_back":
			$AnimationPlayer.play("options_back")
		"credits_back":
			$AnimationPlayer.play("credits_back")
		
