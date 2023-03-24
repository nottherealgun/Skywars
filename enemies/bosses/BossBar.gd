extends Control

var boss : Node

func _process(delta):
	visible = (is_instance_valid(boss))
	if is_instance_valid(boss):
		$BarProgress.value = (boss.health*1000)/boss.max_health
		
func set_boss(new_boss:Node):
	boss = new_boss
	$BossName.text = "[center][shake]"+boss.display_name
	$BossDesc.text = "[center][shake]"+boss.display_desc
	
	var tween := create_tween()
	tween.tween_property($BossName,"visible_ratio",1.0,3.0).from(0.0)
	tween.chain().tween_property($BossDesc,"visible_ratio",1.0,3.0).from(0.0)
