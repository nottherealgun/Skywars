extends Node

var type = "slowness"
var duration = 3
var victim
var stack = 0

func activate():
	victim = get_parent()
	for b in victim.get_children():
		if b == self or !is_instance_valid(b):
			continue
		elif b.is_in_group("buff"):
			if b.type == type:
				stack += b.stack + 1
				duration += b.duration
				if stack > 2:
					queue_free()
					return
				b.get_node("Timer").stop()
				b.queue_free()
				
	duration = clampf(duration,0,6)
	$Timer.start(duration)
	match type:
		"slowness":
			victim.speed = victim.speed*0.9
		"damage_block":
			pass

func _on_timer_timeout():
	if is_instance_valid(victim):
		match type:
			"slowness":
				victim.speed = victim.DEFAULT.speed
	queue_free()
