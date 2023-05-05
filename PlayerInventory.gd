extends Control

var inventory_opened = false
var init = false

var inventory = [] # This variable represents the entire inventory.
var shown_inventory = [] # This variable represents a set of 15 slots of the inventory that are displayed on-screen.
var inv_set_idx := 1
var player_equipped_slots = [null] # Player IDs start from 1, Not 0. Which is why this array at index 0 is occupied.
var player_hovering_slots = [null]
var player_hovering_slot_ids = [null]
var mouse_hovering_slot

func _ready():
	for i in get_children():
		if i.is_in_group("item_slot"):
			if i.get_node_or_null("Button") != null:
				i.get_node("Button").connect("mouse_entered",mouse_entered.bind(i.name))
				i.get_node("Button").connect("mouse_exited",mouse_exited.bind(i.name))
				i.get_node("Button").connect("pressed",slot_pressed.bind(i.name))
	
func start():
	init = true
	for p in Global.active_players:
		var new_player_slot = $PlayerSlot.duplicate()
		new_player_slot.show()
		$HBox.add_child(new_player_slot)
		new_player_slot.get_node("PlayerSlotIcon").texture = load("res://players/"+str(p.character)+"_head.png")
		player_equipped_slots.append({})
		player_hovering_slots.append(0)
		player_hovering_slot_ids.append(-1)
	
	add_item(Global.items[0])
	add_item(Global.items[1])
	add_item(Global.items[2])
	add_item(Global.items[3])
	add_item(Global.items[4])
	add_item(Global.items[7])
	add_item(Global.items[12])
	add_item(Global.items[15])
	add_item(Global.items[16])
	add_item(Global.items[17])
	add_item(Global.items[18])
	
func _process(_delta):
	$Page.text = "Page " + str(inv_set_idx) + "/" + str(floor(inventory.size()/16)+1)
	if init and visible:
		_input_update()
		refresh_inv()

func _input_update():
	if Input.is_action_just_pressed("p1_primary"):
		pass
	elif Input.is_action_just_pressed("p1_secondary"):
		if player_hovering_slots[1] is Dictionary:
			if player_hovering_slots[1].type == "trinket":
				player_equipped_slots[1] = player_hovering_slots[1]
				Global.active_players[0].emit_signal("equips_item",player_equipped_slots[1])
				Global.active_players[0].stat_gui.get_node("EquippedItem/Texture").texture =\
				load("res://items/"+player_equipped_slots[1]["pic"])
			elif player_hovering_slots[1].type == "consumable":
				Global.active_players[0].emit_signal("consumes_item",player_hovering_slots[1])
				remove_item(player_hovering_slot_ids[1])
		
func refresh_inv():
	for i in shown_inventory.size():
		var slot = get_node("ItemSlot"+str(i))
		slot.texture = null
	
	shown_inventory.clear()
	
	for i in inventory.size():
		if (i > (15 * (inv_set_idx - 1)) - 1) and (i < 15 * inv_set_idx):
			shown_inventory.append(inventory[i])
	
	for i in shown_inventory.size():
		var item = shown_inventory[i]
		var slot = get_node("ItemSlot"+str(i))
		
		var texture = load("res://items/"+item["pic"]) as Texture2D
		slot.texture = texture
		match texture.get_height():
			32:
				slot.scale=Vector2.ONE
			64:
				slot.scale=Vector2(2,2)
	
	for i in $HBox.get_children():
		var equip_slot = i.get_node("PlayerSlotItem")
		var equip_slot_in_array = player_equipped_slots[$HBox.get_children().find(i)+1]
		if equip_slot_in_array is Dictionary:
			if equip_slot_in_array != {}:
				equip_slot.texture = load("res://items/"+equip_slot_in_array["pic"])

func add_item(item:Dictionary):
	inventory.append(item)
	return item

func remove_item(slot_id=-1):
	if slot_id >= 0:
		inventory.remove_at(slot_id)

func mouse_entered(slot:String):
	var slot_id = slot.substr(7).to_int()
	player_hovering_slot_ids[1] = slot_id
	mouse_hovering_slot = get_node("./"+slot)
	$Selector.position = mouse_hovering_slot.position-Vector2(13,13)
	if shown_inventory.size() > slot_id:
		if shown_inventory[slot_id] != null:
			player_hovering_slots[1] = shown_inventory[slot_id]
		else:
			player_hovering_slots[1] = 0
	
	if player_hovering_slots[1] is Dictionary:
		$ItemDescription.text = "[center]"+player_hovering_slots[1]["name"]+"[/center]\n\n"
		$ItemDescription.text += player_hovering_slots[1]["desc"]
		$ItemDescription.text += "\n[center][color=gray]- Stats -[/color][/center][color=green]\n"+player_hovering_slots[1]["stats"]

func mouse_exited(slot:String):
	for i in player_hovering_slots:
		if i != null:
			if i is Dictionary:
				player_hovering_slots[player_hovering_slots.find(i)] = 0

func slot_pressed(slot:String):
#	if player_hovering_slots[1] is Dictionary:
#		$ItemDescription.text = "[center]"+player_hovering_slots[1]["name"]+"[/center]\n\n"
#		$ItemDescription.text += player_hovering_slots[1]["desc"]
	pass

func _on_prev_pressed():
	if inv_set_idx > 1:
		inv_set_idx -= 1

func _on_next_pressed():
	if inv_set_idx < floor(inventory.size()/16)+1:
		inv_set_idx += 1
