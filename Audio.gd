extends TabBar

var master = AudioServer.get_bus_index("Master")
var music = AudioServer.get_bus_index("Music")
var sfx = AudioServer.get_bus_index("SFX")
var voicelines = AudioServer.get_bus_index("Voicelines")

func _ready():
	for c in get_children():
		if c is HSlider:
			c.value_changed.connect(self.setting_changed.bind(c.name))

func setting_changed(value:float,setting:String):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(setting), value-45.0)
