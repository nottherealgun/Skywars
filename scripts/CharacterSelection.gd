extends Control
signal changed_player_amount(players)

var players := 1 : set = _set_players

func _ready():
	get_node("1P").toggled.connect(player_pressed.bind(get_node("1P")))
	get_node("2P").toggled.connect(player_pressed.bind(get_node("2P")))
	changed_player_amount.connect($CharacterSelectionBox.changed_player_amount)
	
func _set_players(val):
	players = val
	emit_signal("changed_player_amount",val)

func player_pressed(button_pressed:bool,button:Object):
	for b in get_children():
		if is_instance_of(b,Button):
			b.disabled = false
			b.button_pressed = false
	button.disabled = true
	players = button.get_meta("amnt")
	$AudioManager.play("Click")

func _on_begin_pressed():
	$AudioManager.play("Click")
	$"../MainMenu".start_game($Selector.get_item_text($Selector.get_selected_id()),players)
	$Begin.disabled = true
	await Global.built_level
	hide()
	$Begin.disabled = false
