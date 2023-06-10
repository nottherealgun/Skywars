extends Control

@export var skip_splashscreen = false
@onready var testmap = load("res://rooms/"+Global.rooms[2].file).instantiate()

func _ready():
	$PlayButton.pressed.connect(button_pressed.bind("play"))
	$OptionsButton.pressed.connect(button_pressed.bind("options"))
	$CreditsButton.pressed.connect(button_pressed.bind("credits"))
	$QuitButton.pressed.connect(button_pressed.bind("quit"))
#	$Options/Back.pressed.connect(button_pressed.bind("options_back"))
	$"../SettingsMenu/Back".pressed.connect(button_pressed.bind("options_back"))
	$Credits/Back.pressed.connect(button_pressed.bind("credits_back"))
	
	$"../Splashscreen/AnimationPlayer".play("splashscreen")
	if skip_splashscreen:
		$"../Splashscreen/AnimationPlayer".seek(9.5)
	call_deferred("start_game","darwin")

func _input(event):
	if Input.is_key_pressed(KEY_SPACE):
#		$"../Splashscreen/AnimationPlayer".play("splashscreen")
		pass

func button_pressed(button:String):
	$AudioStreamPlayer.play()
	match button:
		"play":
			$AnimationPlayer.play("clear")
			$"../CharacterSelection".show()

		"options":
			$AnimationPlayer.play("options")
			$"../SettingsMenu/AnimationPlayer".play("enter")
			
		"credits":
			$AnimationPlayer.play("credits")
			$Credits.reset_autoscroll()
		"quit":
			get_tree().quit()
		
		"options_back":
			$AnimationPlayer.play("options_back")
			
		"credits_back":
			$AnimationPlayer.play("credits_back")
		
func start_game(character:String):
	hide()
	$CanvasLayer.hide()
	var new_player = load("res://players/player.tscn").instantiate()
	new_player.character = character.to_lower()
	Global.Main.add_child(new_player)
	Global.active_players.append(new_player)
	Global.RNG.set_seed(int("test"))
	GameManager._game_start()
	Global.build_stage()
	$AnimationPlayer.play("opening")
	
