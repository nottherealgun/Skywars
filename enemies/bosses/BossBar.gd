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
	show()
	var tween := create_tween()
	tween.tween_property($BossName,"visible_ratio",1.0,3.0).from(0.0)
	tween.chain().tween_property($BossDesc,"visible_ratio",1.0,3.0).from(0.0)
	for c in get_children():
		tween = create_tween()
		tween.chain().tween_property(c,"position:y",c.position.y,3.0).from(1200).set_trans(Tween.TRANS_CUBIC)

func boss_died():
	var tween := create_tween()
	for c in get_children():
		tween = create_tween()
		tween.chain().tween_property(c,"position:y",1200,3.0).set_trans(Tween.TRANS_CUBIC)
	tween.chain().tween_callback(self.hide)
