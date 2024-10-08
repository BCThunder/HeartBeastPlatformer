extends CenterContainer

@onready var start_button = %StartButton

func _ready():
	RenderingServer.set_default_clear_color(Color.BLACK)
	start_button.grab_focus()

func _on_start_button_pressed():
	await LevelTransition.fade_to_black()
	get_tree().change_scene_to_file("res://scenes/level_1.tscn")
	LevelTransition.fade_from_black()

func _on_quit_button_pressed():
	get_tree().quit()
