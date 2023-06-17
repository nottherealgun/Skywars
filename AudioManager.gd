extends Node
signal played_track(track:String)
signal stopped_track(track:String)

@export var volume = -15 # dB
var audio_nodes = []

func _ready():
	audio_nodes = get_children()
	get_parent().tree_exiting.connect(deleted)

func deleted():
	stop_all()

func play(track:String):
	get_node(track).play()
	emit_signal("played_track",track)
	return track

func stop(track:String):
	get_node(track).stop()
	emit_signal("stopped_track",track)

func stop_all():
	for a in audio_nodes:
		emit_signal("stopped_track",a.name)
		a.stop()

func set_stream(track:String,stream:AudioStream):
	get_node(track).stream = stream
