extends Node2D

@onready var new_game_button: Button = %NewGameButton
@onready var quit_button: Button = %QuitButton

func _ready():
    # Connect signals
    new_game_button.pressed.connect(_on_new_game_button_pressed)
    quit_button.pressed.connect(_on_quit_button_pressed)
    # TitleScreen only needs to listen
    SceneManager.transition_out_completed.connect(_on_transition_out_completed, CONNECT_ONE_SHOT)

# Start a new game
func _on_new_game_button_pressed():
    SceneManager.transition_out()

func _on_transition_out_completed():
    SceneManager.change_scene("res://scenes/main_scene.tscn")

# Quit the game
func _on_quit_button_pressed():
    get_tree().quit()
