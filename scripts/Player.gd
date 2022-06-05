extends Node2D

var isActive:bool = true
var isPlayer: bool = true
var isLoose: bool = false
var playerNum: int
var textPlayer: String = ""

onready var animation = get_node("AnimatedSprite")
onready var playerStatus = get_node("player_tatus")


# Called when the node enters the scene tree for the first time.
func _ready():
	animation.play("iswaiting")
	playerStatus.play("player")


func reset():
	isLoose = false
	if isActive:
		set_player()


func set_player():
	if isPlayer:
		playerStatus.play("player")
	else:
		playerStatus.play("nonplayer")


func set_loose():
	isLoose = true
	if isPlayer:
		playerStatus.play("player_loose")
	else:
		playerStatus.play("nonplayer_loose")


func set_waiting():
	animation.play("iswaiting")


func set_playing():
	animation.play("isplaying")


func set_type():
	isLoose = false
	if !isActive:
		isActive = true
		isPlayer = true
		set_player()
	elif isPlayer:
		isPlayer = false
		set_player()
	else:
		isActive = false
		playerStatus.play("disabled")


func is_player():
	return isPlayer


func is_active():
	return isActive


func is_loose():
	return isLoose
