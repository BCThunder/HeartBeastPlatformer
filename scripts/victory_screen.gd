extends CenterContainer

@onready var menu_button = %MenuButton

func _ready():
	LevelTransition.fade_from_black()
	menu_button.grab_focus()

func _on_button_pressed():
	get_tree().change_scene_to_file("res://scenes/start_menu.tscn")
