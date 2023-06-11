extends Control

func _on_button_pressed():
	$"../MainMenu".start_game($Selector.get_item_text($Selector.get_selected_id()))
	await Global.built_level
	hide()
