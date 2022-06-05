extends Spatial

onready var volumeSlider: Slider = get_node("CanvasLayer/SliderVolume")
onready var crocodileAnimation: AnimationPlayer = get_node("CrocodileHead/AnimationPlayer")
onready var buttonPlay: Button = get_node("CanvasLayer/ButtonPlay")
onready var buttonContinue: Button = get_node("CanvasLayer/ButtonContinue")
onready var labelPlay: Label = get_node("CanvasLayer/LabelPlay")
onready var labelIndicator: Label = get_node("CanvasLayer/LabelIndicator")
onready var containerButtonTooth = get_node("CanvasLayer/ContainerButtonChoice")
# Declare member variables here. Examples:
var badTooth: int = 0
var player: int = 0
var isPlaying: bool = false
var cooldown: bool = false
var playedTooth: int = 0

var players = {}
var playing = []

const botTimerTime: float = 2.0
var botTimer: float = botTimerTime
var botIsPlaying: bool = false


# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	players[1] = get_node("Player1")
	players[2] = get_node("Player2")
	players[3] = get_node("Player3")
	players[4] = get_node("Player4")
# warning-ignore:return_value_discarded
	crocodileAnimation.connect("animation_finished", self, "onAnimationPlayeranimationfinished")
	for i in range(1, 14):
		var bt = containerButtonTooth.get_node("ButtonTooth_" + str(i))
		bt.connect("pressed", self, "_some_button_pressed", [bt, i])
	
	volumeSlider.value = Config.get_volume()
	prepare_game()


func _process(delta):
	if isPlaying and botIsPlaying:
		botTimer-= delta
		if botTimer <= 0:
			botIsPlaying = false
			var choice = []
			for i in range(1, 14):
				var bt = get_node("CanvasLayer/ContainerButtonChoice/ButtonTooth_" + str(i))
				if !bt.is_disabled():
					choice.append(i)
			var num = int(rand_range(0, choice.size()))
			get_node("CanvasLayer/ContainerButtonChoice/ButtonTooth_" + str(choice[num])).set_disabled(true)
			set_played_tooth(choice[num])


func prepare_game():
	labelIndicator.visible = false
	labelPlay.visible = false
	containerButtonTooth.visible = false
	buttonContinue.visible = false
	buttonPlay.visible = true
	labelIndicator.text = tr("Choose players")
	labelIndicator.visible = true
	
	for button in get_tree().get_nodes_in_group("button_type"):
		button.visible = true
	for pl in range(1,5):
		players[pl].reset()


func new_game():
	buttonContinue.visible = false
	buttonPlay.visible = false
	for button in get_tree().get_nodes_in_group("button_type"):
		button.visible = false
	set_play()


func set_play():
	playing.clear()
	for pl in range(1,5):
		if players[pl].is_active() and !players[pl].is_loose():
			playing.append(pl)
	reset()
	players[playing[player]].set_playing()
	if !players[playing[player]].is_player():
		botTimer = botTimerTime
		botIsPlaying = true


func _some_button_pressed(button, i):
	if !isPlaying or cooldown or !players[playing[player]].is_player():
		return
	button.set_disabled(true)
	set_played_tooth(i)


func set_played_tooth(i):
	cooldown = true
	playedTooth = i
	labelPlay.visible = false
	labelIndicator.text = tr("Tooth chosen:") + str(playedTooth)
	labelIndicator.visible = true
	crocodileAnimation.play("tremble")
	get_node("SoundCrocodile").play()
	get_node("CrocodileHead/Tooth_" + str(playedTooth) + "/AnimationPlayer").play("push")


func onAnimationPlayeranimationfinished(animname):
	if animname =="tremble":
		labelIndicator.visible = false
		test_tooth(playedTooth)


func test_tooth(num):
	players[playing[player]].set_waiting()
	if num == badTooth:
		isPlaying = false
		labelIndicator.text = tr("The wrong tooth was the ") + str(badTooth)
		labelIndicator.visible = true
		
		containerButtonTooth.visible = false
		crocodileAnimation.play("close")
		#get_node("SoundCris").play()
		players[playing[player]].set_loose()
		buttonContinue.visible = true
		labelPlay.visible = true
		if playing.size() > 2:
			labelPlay.text = tr("The %color player is eliminated").replace("%color", get_player_color(playing[player]))
		else:
			playing.pop_at(player)
			labelPlay.text = tr("The %color player win").replace("%color", get_player_color(playing[0]))
	else:
		player += 1
		if player >= playing.size():
			player = 0
		players[playing[player]].set_playing()
		if !players[playing[player]].is_player():
			botTimer = botTimerTime
			botIsPlaying = true
		cooldown = false
		update_player_tour()


func get_next_game():
	if playing.size() < 3:
		prepare_game()
	else:
		set_play()


func update_player_tour():
	labelPlay.text = tr("The %color player plays").replace("%color", get_player_color(playing[player]))
	labelPlay.visible = true


func get_player_color(num):
	var color: String
	if num == 1:
		color = tr("red")
	elif num == 2:
		color = tr("green")
	elif num == 3:
		color = tr("blue")
	else:
		color = tr("yellow")
	return color


func rand():
	return int(rand_range(1, 14))


func control():
	var nb = 0
	for pl in range(1,5):
		if players[pl].is_active():
			nb+=1
	if nb > 1:
		buttonPlay.set_disabled(false)
	else:
		buttonPlay.set_disabled(true)


func reset():
	badTooth = rand()
	#print("badTooth: ", badTooth)
	isPlaying = true
	cooldown = false
	player = 0
	
	get_node("CrocodileHead/Tooth_1/AnimationPlayer").play("idle")
	get_node("CrocodileHead/Tooth_2/AnimationPlayer").play("idle")
	get_node("CrocodileHead/Tooth_3/AnimationPlayer").play("idle")
	get_node("CrocodileHead/Tooth_4/AnimationPlayer").play("idle")
	get_node("CrocodileHead/Tooth_5/AnimationPlayer").play("idle")
	get_node("CrocodileHead/Tooth_6/AnimationPlayer").play("idle")
	get_node("CrocodileHead/Tooth_7/AnimationPlayer").play("idle")
	get_node("CrocodileHead/Tooth_8/AnimationPlayer").play("idle")
	get_node("CrocodileHead/Tooth_9/AnimationPlayer").play("idle")
	get_node("CrocodileHead/Tooth_10/AnimationPlayer").play("idle")
	get_node("CrocodileHead/Tooth_11/AnimationPlayer").play("idle")
	get_node("CrocodileHead/Tooth_12/AnimationPlayer").play("idle")
	get_node("CrocodileHead/Tooth_13/AnimationPlayer").play("idle")
	
	for button in get_tree().get_nodes_in_group("buttons_tooth"):
		button.set_disabled(false)
	containerButtonTooth.visible = true
	labelIndicator.visible = false
	buttonContinue.visible = false
	crocodileAnimation.play("idle")
	update_player_tour()


func _on_ButtonBackMenu_pressed():
# warning-ignore:return_value_discarded
	get_tree().change_scene("res://scenes/Menu.tscn")


func _on_SliderVolume_value_changed(value):
	Config.set_volume(value)


func _on_ButtonContinue_pressed():
	get_next_game()


func _on_ButtonChoicePlayer_1_pressed():
	players[1].set_type()
	control()


func _on_ButtonChoicePlayer_2_pressed():
	players[2].set_type()
	control()


func _on_ButtonChoicePlayer_3_pressed():
	players[3].set_type()
	control()


func _on_ButtonChoicePlayer_4_pressed():
	players[4].set_type()
	control()


func _on_ButtonPlay_pressed():
	new_game()
