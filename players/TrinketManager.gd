extends Node

@onready var user = get_parent()
var equipped_trinket = null

func _ready():
	user.spawns_bullet.connect(spawned_bullet)
	user.spawns_minion.connect(spawned_minion)
	user.equips_item.connect(equip_item)
	user.consumes_item.connect(consumes_item)

func equip_item(item:Dictionary):
	reset_buffs()
	equipped_trinket = item
	match item.name:
		"Amulet of Dood":
			for m in user.minions:
				if !is_instance_valid(m):
					user.minions.erase(m)
					continue
				m.damage *= 1.1
		"Walker's Special":
			user.attack_speed *= 0.9
		"Worrier Froge":
			user.dash_modifier *= 1.3
		"Kouprey's Horn":
			user.damage_modifier *= 1.1
		"Konit's Brick":
			user.damage_reduction = 15

func consumes_item(item:Dictionary):
	match item.name:
		"Salmon Nigiri":
			user.health += user.max_health*0.2
		"Tonkatsu Curry":
			user.health = user.max_health
		"Khao Mun Gai":
			user.health += user.max_health*0.75
		"Ohm's Gyoza":
			user.health += user.max_health*0.5
		"Dispensed Water":
			pass
		"The Walker Espress":
			pass
		"American-O":
			pass
		"Cap's Mustache":
			pass
		"Shot O' Latte":
			pass
		"De Moch Crazy":
			pass
		"Dirty Bean Juice":
			pass
		

func spawned_bullet(bullet:Object):
	randomize()
	if equipped_trinket != null:
		match equipped_trinket.name:
			"NotTheRealGun":
				var r = randi_range(1,100)
				if r <= 5:
					bullet.damage *= 2
			"The Ice of Ice":
				var new_buff = $Buff.duplicate()
				new_buff.type = "slowness"
				bullet.add_child(new_buff)

func spawned_minion(minion:Object):
	if equipped_trinket != null:
		match equipped_trinket.name:
			"Amulet of Dood":
				minion.damage *= 1.1

func reset_buffs():
	user.max_health = user.DEFAULT.max_health
	user.damage_modifier = user.DEFAULT.damage_modifier
	user.speed = user.DEFAULT.speed
	user.attack_speed = user.DEFAULT.attack_speed
	user.dash_modifier = user.DEFAULT.dash_modifier
	user.damage_reduction = user.DEFAULT.damage_reduction
	
	for m in user.minions:
		if !is_instance_valid(m):
			continue
		m.max_health = m.DEFAULT.max_health
		m.damage = m.DEFAULT.damage
		m.speed = m.DEFAULT.speed
