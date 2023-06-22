extends Label

func display(txt:String):
	text = txt
	var tween = create_tween()
	tween.tween_property(self,"modulate",Color.TRANSPARENT,4.0).from(Color.WHITE)
