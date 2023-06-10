extends Control

var boss : Node

func _process(_delta):
	if is_instance_valid(boss):
		$BarProgress.value = (boss.health*1000)/boss.max_health
		$BossHealth.text = str(clampf(boss.health,0,boss.max_health))+"/"+ str(boss.max_health)
		
func set_boss(new_boss:Node):
	boss = new_boss
	boss.died.connect(self.boss_died)
	$BossName.text = "[center][shake]"+boss.display_name
	$BossDesc.text = "[center][shake]"+boss.display_desc
	
#	await boss.started
	var tween = create_tween()
	tween.tween_property($BossName,"visible_ratio",1.0,3.0).from(0.0)
	tween.parallel().tween_property($BossDesc,"visible_ratio",1.0,3.0).from(0.0)
	for c in get_children():
		tween.parallel().tween_property(c,"position:y",-240,3.0).as_relative().set_trans(Tween.TRANS_CUBIC)
		

func boss_died():
	GameManager.bosses_vanquished += 1
	var tween := create_tween()
	tween.tween_property(%Flash,"modulate",Color.TRANSPARENT,1.0).from(Color.WHITE)
	for c in get_children():
		tween.parallel().tween_property(c,"position:y",240,3.0).as_relative().set_trans(Tween.TRANS_CUBIC)
#	tween.parallel().tween_property(Global.Cam,"zoom",Vector2.ONE*1.5,3.0)
