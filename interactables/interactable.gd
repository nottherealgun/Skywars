class_name Interactable extends Node2D

var surrounding_affectors = []

func _process(delta):
	pass
#
#func _on_hitbox_area_entered(area):
#	var entity = area.get_parent()
#	if entity.is_in_group("player") or  entity.is_in_group("enemy"):
#		if not entity in surrounding_affectors:
#			surrounding_affectors.append(entity)
#
#func _on_hitbox_area_exited(area):
#	surrounding_affectors.erase(area.get_parent())
