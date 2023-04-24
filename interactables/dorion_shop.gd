extends StaticBody2D

@onready var tween : Tween

var inspecting_item_id := 0

@onready var item_slots = [%Item1,%Item2]
var original_offsets = [] # Animation Purposes
var items = []

func _ready():
	for i in item_slots:
		original_offsets.append(i.offset)
	refresh_stock()

func refresh_stock():
	items = []
	for i in item_slots.size():
		var new_item = Global.items[randi_range(15,25)]
		while new_item in items or new_item == null:
			new_item = Global.items[randi_range(15,25)]
		items.append(new_item)
		if new_item["pic"] != "":
			item_slots[i].texture = load("res://items/"+new_item["pic"])
			item_slots[i].get_node("../../Desc/Label").text = new_item["name"]
			item_slots[i].get_node("../../Desc/ScrollContainer/Label").text = new_item["desc"]
			item_slots[i].get_node("../../Desc/Stats/Label").text = "Stats:\n"+new_item["stats"]
			item_slots[i].get_node("../../Desc/Cost").text = "Cost:   "+str(new_item["cost"])
			item_slots[i].scale = Vector2.ONE * new_item["scale_factor"]
		else:
			item_slots[i].texture = null
			item_slots[i].get_node("../../Desc/Label").text = ""
			item_slots[i].get_node("../../Desc/ScrollContainer/Label").text = "Out of Stock."
			item_slots[i].get_node("../../Desc/Cost").text = "Cost:   -"
			
	
func buy(for_player):
	var bought_item = items[inspecting_item_id]
	if not bought_item in [null,{}]:
		if GameManager.money >= bought_item.cost:
			GameManager.add_money(-bought_item.cost)
			Global.Inventory.add_item(bought_item)
			items[inspecting_item_id] = {}
			item_slots[inspecting_item_id].texture = null
			item_slots[inspecting_item_id].get_node("../../Desc/Label").text = "(SOLD)"
			item_slots[inspecting_item_id].get_node("../../Desc/Stats/Label").text = ""
			item_slots[inspecting_item_id].get_node("../../Desc/ScrollContainer/Label").text = "Item Sold."
			item_slots[inspecting_item_id].get_node("../../Desc/Cost").text = "Cost:   -"

func _on_area_area_entered(area):
	var entity = area.get_parent()
	if entity.is_in_group("player"):
		if !entity.is_connected("action",buy):
			entity.connect("action",buy)

		tween = create_tween().set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
		tween.tween_property($Label,"scale",Vector2.ONE,2.0).from_current()

func _on_area_area_exited(area):
	var entity = area.get_parent()
	if entity.is_in_group("player"):
		if entity.is_connected("action",buy):
			entity.disconnect("action",buy)
		tween.stop()
		tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
		tween.tween_property($Label,"scale",Vector2.ZERO,0.25).from_current()

func _on_item_1_area_entered(area):
	var entity = area.get_parent()
	if entity.is_in_group("player"):
		inspecting_item_id = 0
		var tween2 := create_tween().set_trans(Tween.TRANS_CUBIC)
		tween2.tween_property(item_slots[0],"offset:y",-5,0.25).as_relative()
		tween2.tween_property(item_slots[0].get_node("../../Desc"),"scale",Vector2.ONE,0.25)

func _on_item_2_area_entered(area):
	var entity = area.get_parent()
	if entity.is_in_group("player"):
		inspecting_item_id = 1
		var tween2 := create_tween().set_trans(Tween.TRANS_CUBIC)
		tween2.tween_property(item_slots[1],"offset:y",-5,0.25).as_relative()
		tween2.tween_property(item_slots[1].get_node("../../Desc"),"scale",Vector2.ONE,0.25)

func _on_item_interact_1_area_exited(area):
	var tween2 := create_tween()
	tween2.tween_property(item_slots[0],"offset:y",original_offsets[0].y,0.25)
	tween2.tween_property(item_slots[0].get_node("../../Desc"),"scale",Vector2.ZERO,0.25)

func _on_item_interact_2_area_exited(area):
	var tween2 := create_tween()
	tween2.tween_property(item_slots[1],"offset:y",original_offsets[1].y,0.25)
	tween2.tween_property(item_slots[1].get_node("../../Desc"),"scale",Vector2.ZERO,0.25)
