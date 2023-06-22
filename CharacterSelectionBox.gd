extends HFlowContainer
signal changed_player_chosen_chars(arr)

@onready var p1 = $Unchosen/PlayerCircle1
@onready var p2 = $Unchosen/PlayerCircle2
@onready var p3 = $Unchosen/PlayerCircle3
@onready var p4 = $Unchosen/PlayerCircle4

@onready var active_players = [p1]
var active_player_ids = [-1,-1,-1,-1]
var active_player_characters = ["darwin","gun"]

@onready var characters = [$Darwin,$Gun]

func _ready():
	p1.show()

func _input(event):
	for p in [1,2]:
		if event.is_action_pressed("p"+str(p)+"_right"):
			if active_player_ids[p-1] < len(characters):
				active_player_ids[p-1] += 1
				
		elif event.is_action_pressed("p"+str(p)+"_left"):
			if active_player_ids[p-1] > -1:
				active_player_ids[p-1] -= 1
	
	update()

func update():
	var p_chosen_chars = []
	for p in active_players:
		var char_select = characters[active_player_ids[active_players.find(p)]-1]
		if p.get_parent() != char_select.get_node("Flowbox"):
			p.get_parent().remove_child(p)
			char_select.get_node("Flowbox").add_child(p)
			p.set_meta("char",char_select.name.to_lower())
		p_chosen_chars.append(char_select.name.to_lower())
	emit_signal("changed_player_chosen_chars",p_chosen_chars)

func changed_player_amount(amnt:int):
	active_players.clear()
	for p in [p1,p2,p3,p4]:
		p.hide()
	p1.show()
	if amnt > 1:
		p2.show()
	if amnt > 2:
		p3.show()
	if amnt > 3:
		p4.show()
	
	for p in [p1,p2,p3,p4]:
		if p.visible:
			active_players.append(p)
