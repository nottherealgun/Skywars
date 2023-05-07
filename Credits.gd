extends Control

@onready var scrollbar = $Text.get_v_scroll_bar() as VScrollBar
var tween : Tween

func reset_autoscroll():
	tween = create_tween()
	tween.tween_property(scrollbar,"value",scrollbar.max_value-1080,30).from(0)
