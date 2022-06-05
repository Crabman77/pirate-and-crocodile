extends Node2D


func _on_ButtonPirate_pressed():
	var error_code = get_tree().change_scene("res://pirate/scenes/PirateScene.tscn")
	if error_code != 0:
		print("ERROR: ", error_code)


func _on_ButtonCroco_pressed():
	var error_code = get_tree().change_scene("res://crocodile/scenes/CrocodileScene.tscn")
	if error_code != 0:
		print("ERROR: ", error_code)


func _on_ButtonOptions_pressed():
	pass # Replace with function body.


func _on_ButtonQuit_pressed():
	Config.save()
	get_tree().quit()
