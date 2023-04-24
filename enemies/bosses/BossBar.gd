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
	
	await boss.started
	var tween := create_tween()
	tween.tween_property($BossName,"visible_ratio",1.0,3.0).from(0.0)
	tween.parallel().tween_property($BossDesc,"visible_ratio",1.0,3.0).from(0.0)
	for c in get_children():
		tween.parallel().tween_property(c,"position:y",c.position.y,3.0).from(1200).set_trans(Tween.TRANS_CUBIC)
		tween.parallel().tween_callback(c.show)

func boss_died():
	var tween := create_tween()
	tween.tween_property(%Flash,"modulate",Color.TRANSPARENT,1.0).from(Color.WHITE)
	for c in get_children():
		tween.parallel().tween_property(c,"position:y",1200,3.0).set_trans(Tween.TRANS_CUBIC)
	await tween.finished
	for c in get_children():
		c.hide()
	
