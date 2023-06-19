extends Interactable

var item
var money = 100
var opened = false
var collected = false

func open(player):
	var tween = create_tween().set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self,"scale",Vector2(1.0,1.0),0.2).from(Vector2(1,1)*0.9)
	
	if !opened:
		$AnimatedSprite2D.play("default")
		await $AnimatedSprite2D.animation_finished
		opened = true
	if opened:
		if !collected:
			item = Global.items[randi_range(0,9)]
			Global.Inventory.add_item(item)
			GameManager.add_money(money)
			collected = true
			item_effect()
		money_effect()
		
func _on_hitbox_area_entered(area):
	var entity = area.get_parent()
	if entity.is_in_group("player"):
		if !entity.is_connected("does_action",open):
			entity.connect("does_action",open)

func _on_hitbox_area_exited(area):
	var entity = area.get_parent()
	if entity.is_in_group("player"):
		if entity.is_connected("does_action",open):
			entity.disconnect("does_action",open)

func item_effect():
	var t = create_tween().set_trans(Tween.TRANS_CUBIC)
	$ItemShow.texture = load("res://items/"+item.pic)
	$Label.text = item.name
	$ItemShow/Par.emitting = true
	t.tween_property($ItemShow,"position:y",-100,1.0).as_relative()
	t.parallel().tween_property($ItemShow,"scale",Vector2.ONE*3,1.0).from(Vector2.ZERO)
	t.chain().tween_property($ItemShow,"position:y",-100,1.0)
	await t.finished
	t.kill()
	t = create_tween().set_trans(Tween.TRANS_CUBIC)
	t.set_loops()
	t.chain().tween_property($ItemShow,"position:y",15,1.0).as_relative()
	t.parallel().tween_property($Label,"position:y",15,1.0).as_relative()
	t.chain().tween_property($ItemShow,"position:y",-15,1.0).as_relative()
	t.parallel().tween_property($Label,"position:y",-15,1.0).as_relative()
	if $ItemShow.texture == null:
		t.kill()
		
func money_effect():
	for i in 5:
		var new_coin = $CoinTemplate.duplicate()
		new_coin.template = false
		new_coin.show()
		add_child(new_coin)
		await get_tree().create_timer(0.01).timeout
