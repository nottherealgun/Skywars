extends Control

@export var skip_splashscreen = false
@export var testmap : PackedScene

func _ready():
	$PlayButton.pressed.connect(button_pressed.bind("play"))
	$OptionsButton.pressed.connect(button_pressed.bind("options"))
	$CreditsButton.pressed.connect(button_pressed.bind("credits"))
	$QuitButton.pressed.connect(button_pressed.bind("quit"))
	$"../SettingsMenu/Back".pressed.connect(button_pressed.bind("options_back"))
	$Credits/Back.pressed.connect(button_pressed.bind("credits_back"))
	
	$"../Splashscreen/AnimationPlayer".play("splashscreen")
	if skip_splashscreen:
		$"../Splashscreen/AnimationPlayer".seek(9.5)

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
		"quit": get_tree().quit()
		"options_back":$AnimationPlayer.play("options_back")
		"credits_back":$AnimationPlayer.play("credits_back")

var player_chosen_chars = ["darwin","gun","darwin","darwin"]

func start_game(character:String,player_amnt:int):
	for p in range(player_amnt):
		var new_player = load("res://assets/players/player.tscn").instantiate()
		new_player.character = player_chosen_chars[p]
		new_player.player_id = p+1
		Global.Main.add_child(new_player)
		Global.active_players.append(new_player)
	
	GameManager._game_start()
	Global.build_lobby()
	await Global.built_level
	$AnimationPlayer.play("opening")
	hide()

func _on_character_selection_box_changed_player_chosen_chars(arr):
	player_chosen_chars = arr
	while len(arr) < 4:
		player_chosen_chars.append("darwin")
