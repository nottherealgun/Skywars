extends Control

signal reviewed
var can_continue = false
const new_record = "[wave amp=50 freq=10][color=yellow]* NEW RECORD! *[/color][/wave]\n"

func _input(event):
	if can_continue and event.is_pressed():
		can_continue = false
		var t = create_tween()
		t.tween_property($Blur,"material:shader_parameter/blur_amount",0.0,.5)
		t.parallel().tween_property($Title,"visible_ratio",0.0,.25)
		t.chain().tween_property($Info,"visible_ratio",0.0,1.0)
		await t.finished
		$AnimationPlayer.play("exit")
		await $AnimationPlayer.animation_finished
		GameManager.game_reset(false)
		emit_signal("reviewed")

func display(lvls,rooms,kills,bosses,time:Dictionary):
	var f = FileAccess.open("res://scoreboard.json",1)
	var raw = f.get_as_text()
	var data = JSON.parse_string(raw)["highscore"] as Dictionary
	f.close()
	
	var prev_total = data.levels_cleared*3+data.rooms_cleared*2+data.bosses_vanquished*2
	var new_total = lvls*3 + rooms*2 + kills + bosses*2
	
	$Info.text = "[p align=center]\n"
	if new_total > prev_total:
		$Info.text += new_record
	else:
		$Info.text += "\n"
	$Info.text += "- You -\n"
	$Info.text += "Levels Cleared: %s" % [str(lvls)]
	$Info.text += "\nRooms Cleared: %s" % [str(rooms)]
	$Info.text += "\nEnemies Killed: %s" % [str(kills)]
	$Info.text += "\nBosses Vanquished: %s" % [str(bosses)]
	$Info.text += "\nTotal Playtime: %s HRS, %s MIN, %s SEC" % [time.hrs,time.min,time.sec]
	
	$Info.text += "[p align=center]\n"
	$Info.text += "- Highest Scored Player -\n"
	$Info.text += "Levels Cleared: %s" % [str(data.levels_cleared)]
	$Info.text += "\nRooms Cleared: %s " % [str(data.rooms_cleared)]
	$Info.text += "\nEnemies Killed: %s" % [str(data.enemies_killed)]
	$Info.text += "\nBosses Vanquished: %s" % [str(data.bosses_vanquished)]
	$Info.text += "\nTotal Playtime: %s HRS, %s MIN, %s SEC" % [data.playtime.hrs,data.playtime.min,data.playtime.sec]
	
	if new_total > prev_total:
		f = FileAccess.open("res://scoreboard.json",2)
		var temp = {"highscore":{
				"levels_cleared":lvls,
				"rooms_cleared":rooms,
				"enemies_killed":kills,
				"bosses_vanquished":bosses,
				"playtime":{
					"hrs":time.hrs,
					"min":time.min,
					"sec":time.sec
				}
			}
		}
		f.store_string(JSON.stringify(temp,"\t"))
		f.close()
	$Timer.start()
	$AnimationPlayer.play("enter")
	await $AnimationPlayer.animation_finished
	var t = create_tween()
	t.tween_property($Blur,"material:shader_parameter/blur_amount",0.5,1.0).from(0.0)
	t.parallel().tween_property($Title,"visible_ratio",1.0,.25).from(0.0)
	t.chain().tween_property($Info,"visible_ratio",1.0,2.0).from(0.0)
	
func _on_timer_timeout():
	can_continue = true
