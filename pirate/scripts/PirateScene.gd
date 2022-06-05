extends Spatial

onready var sceneSword1 = preload("res://pirate/scenes/Sword1.tscn")
onready var sceneSword2 = preload("res://pirate/scenes/Sword2.tscn")
onready var sceneSword3 = preload("res://pirate/scenes/Sword3.tscn")
onready var sceneSword4 = preload("res://pirate/scenes/Sword4.tscn")

onready var volumeSlider: Slider = get_node("CanvasLayer/SliderVolume")
onready var pirateAnimation: AnimationPlayer = get_node("PersoPirate").get_node("AnimationPlayer")
onready var buttonPlay: Button = get_node("CanvasLayer/ButtonPlay")
onready var buttonContinue: Button = get_node("CanvasLayer/ButtonContinue")
onready var labelPlay: Label = get_node("CanvasLayer/LabelPlay")
onready var labelIndicator: Label = get_node("CanvasLayer/LabelIndicator")
onready var containerButtonSwords = get_node("CanvasLayer/ContainerButtonChoice")
# Declare member variables here. Examples:
var badSword: int = 0
var player: int = 0
var isPlaying: bool = false
var cooldown: bool = false
var playedSword: int = 0

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
	pirateAnimation.connect("animation_finished", self, "onAnimationPlayeranimationfinished")
	for i in range(1, 25):
		var bt = containerButtonSwords.get_node("ButtonSword_" + str(i))
		bt.connect("pressed", self, "_some_button_pressed", [bt, i-1])
		
	volumeSlider.value = Config.get_volume()
	prepare_game()


func _process(delta):
	if isPlaying and botIsPlaying:
		botTimer-= delta
		if botTimer <= 0:
			botIsPlaying = false
			var choice = []
			for i in range(1, 25):
				var bt = get_node("CanvasLayer/ContainerButtonChoice/ButtonSword_" + str(i))
				if !bt.is_disabled():
					choice.append(i)
			var num = int(rand_range(0, choice.size()))
			get_node("CanvasLayer/ContainerButtonChoice/ButtonSword_" + str(choice[num])).set_disabled(true)
			set_played_sword(choice[num]-1)


func prepare_game():
	labelIndicator.visible = false
	labelPlay.visible = false
	containerButtonSwords.visible = false
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
	set_played_sword(i)


func set_played_sword(i):
	cooldown = true
	playedSword = i
	labelPlay.visible = false
	labelIndicator.text = tr("Sword chosen:") + str(playedSword + 1)
	labelIndicator.visible = true
	var sword
	if playing[player] == 1:
		sword = sceneSword1.instance()
	elif playing[player] == 2:
		sword = sceneSword2.instance()
	elif playing[player] == 3:
		sword = sceneSword3.instance()
	else:
		sword = sceneSword4.instance()
	var h 
	var nb
	if playedSword <= 7:
		h = 1.8
		nb = playedSword
	elif playedSword <= 15:
		h = 1.3
		nb = playedSword - 8
	else:
		h = 0.8
		nb = playedSword - 16
	
	sword.translate(Vector3(0, h, 0))
	sword.rotate_y(deg2rad( (20.0 * nb) - 70 ))
	get_node("Barrel").add_child(sword)
	sword.get_node("AnimationPlayer").play("play")
	get_node("SoundSword").play()
	pirateAnimation.play("tremble")


func onAnimationPlayeranimationfinished(animname):
	if animname =="tremble":
		labelIndicator.visible = false
		test_sword(playedSword + 1)


func test_sword(num):
	players[playing[player]].set_waiting()
	if num == badSword:
		isPlaying = false
		labelIndicator.text = tr("The wrong sword was the ") + str(badSword)
		labelIndicator.visible = true
		
		containerButtonSwords.visible = false
		pirateAnimation.play("jump")
		get_node("SoundCris").play()
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
	return int(rand_range(1, 25))


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
	badSword = rand()
	#print("badSword: ", badSword)
	isPlaying = true
	cooldown = false
	player = 0
	for sword in get_tree().get_nodes_in_group("sword"):
		sword.queue_free()
	
	for button in get_tree().get_nodes_in_group("button_swords"):
		button.set_disabled(false)
	containerButtonSwords.visible = true
	labelIndicator.visible = false
	buttonContinue.visible = false
	pirateAnimation.play("idle")
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
