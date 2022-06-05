extends Node


# Create new ConfigFile object.
var conf = ConfigFile.new()
var volume = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	#get_tree().set_auto_accept_quit(false)
	load_conf()


func load_conf():
	var err = conf.load("pirate_conf.cfg")
	if err != OK:
		return
	var window_size = OS.get_screen_size()
	var width
	var height
	if conf.has_section_key("screen", "width") and conf.has_section_key("screen", "height"):
		width = int(conf.get_value("screen", "width"))
		height = int(conf.get_value("screen", "height"))
		if width and height:
			if width < window_size.x and height < window_size.y:
				OS.set_window_size(Vector2(width, height))
	
	if conf.has_section_key("screen", "posx") and conf.has_section_key("screen", "posy"):
		var posx = int(conf.get_value("screen", "posx"))
		var posy = int(conf.get_value("screen", "posy"))
		if posx and posy and posx > -width and posx < window_size.x and posy > -height and posy < window_size.y:
				OS.set_window_position(Vector2(posx, posy))
	
	if conf.has_section_key("screen", "ismax"):
		var ismax = int(conf.get_value("screen", "ismax"))
		if ismax and ismax == 1:
			OS.set_window_maximized(true)
	
	if conf.has_section_key("audio", "volume"):
		var v = int(conf.get_value("audio", "volume"))
		if v:
			set_volume(v)


func save():
	#print("save function")
	var window_size = OS.get_window_size()
	var pos = OS.get_window_position()
	var ismax = int(OS.is_window_maximized())
	conf.set_value("screen", "width", int(window_size.x))
	conf.set_value("screen", "height", int(window_size.y))
	conf.set_value("screen", "posx",int(pos.x))
	conf.set_value("screen", "posy", int(pos.y))
	conf.set_value("screen", "ismax", ismax)
	
	conf.set_value("audio", "volume", volume)
	conf.save("pirate_conf.cfg")


func get_volume():
	return volume


func set_volume(value):
	if value > 0:
		value = 0
	elif value < -24:
		value = -24
	volume = value
	if value < -23:
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), value)
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), true)
	else:
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), value)
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), false)


func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		save()
