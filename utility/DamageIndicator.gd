extends Node2D

var amount = 0
var symbol := ""
var heal = false
var player_bullet = false

func _ready():
	if amount < 0 or heal:
		if amount < 0:
			amount*=-1
		$Label.set("theme_override_colors/font_color",Color.GREEN)
	else:
		if !player_bullet:
			$Label.set("theme_override_colors/font_color",Color.RED)
		
	$Label.text = symbol+str(amount)
	var tween := create_tween()
	tween.tween_property(self,"position",position+Vector2(randf_range(-30.0,30.0),-100),0.5)
	tween.parallel().tween_property(self,"modulate",Color.TRANSPARENT,0.5).from(Color.WHITE)
	tween.parallel().tween_property(self,"scale",Vector2(1,1),0.5).from(Vector2(2,2))
	await tween.finished
	queue_free()
