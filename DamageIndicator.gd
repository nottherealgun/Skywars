extends Node2D

var amount = 0
var sign = ""
var heal = false
func _ready():
	if heal:
		sign == "+"
		$Label.set("theme_override_colors/font_color",Color.GREEN)
	else:
		$Label.set("theme_override_colors/font_color",Color.RED)
		
	$Label.text = sign+str(amount)
	var tween := create_tween()
	tween.tween_property(self,"position",position+Vector2(0,-100),0.5)
	tween.parallel().tween_property(self,"modulate",Color.TRANSPARENT,0.5)
	tween.parallel().tween_property(self,"scale",Vector2(1,1),0.5).from(Vector2(1.5,1.5))
	tween.parallel().tween_property(self,"rotation",deg_to_rad(randf_range(-90,90)),0.5)
	await tween.finished
	queue_free()
