extends Control

signal text_animation_done
signal choice_selected

# Preload the Player Choice scene
const ChoiceButtonScene = preload("res://scenes/player_choice.tscn")

@onready var dialog_line = %DialogLine
@onready var speaker_name = %SpeakerName
@onready var choice_list = %ChoiceList
@onready var text_blip_sound = %TextBlipSound
@onready var text_blip_timer = %TextBlipTimer
@onready var sentence_pause_timer = %SentencePauseTimer

const ANIMATION_SPEED : int = 30
const NO_SOUND_CHARS : Array = [".", "!", "?"]

var animate_text : bool = false
var current_visible_characters : int = 0
var current_character_details : Dictionary

# Called when the node enters the scene tree for the first time.
func _ready():
	# Hide the choice list
	choice_list.hide()
	# Connect signals
	text_blip_timer.timeout.connect(_on_text_blip_timeout)
	sentence_pause_timer.timeout.connect(_on_sentence_pause_timeout)
	
func _process(delta):
	if animate_text and sentence_pause_timer.is_stopped():
		if dialog_line.visible_ratio < 1:
			dialog_line.visible_ratio += (1.0/dialog_line.text.length()) * (ANIMATION_SPEED * delta)
			if dialog_line.visible_characters > current_visible_characters:
				current_visible_characters = dialog_line.visible_characters
				var current_char = dialog_line.text[current_visible_characters - 1]
				if current_visible_characters < dialog_line.text.length():
					var next_char = dialog_line.text[current_visible_characters]
					if NO_SOUND_CHARS.has(current_char) and next_char == " ":
						text_blip_timer.stop()
						sentence_pause_timer.start()
		else:
			animate_text = false
			text_blip_timer.stop()
			text_animation_done.emit()

func change_line(character_name: Character.Name, line: String):
	current_character_details = Character.CHARACTER_DETAILS[character_name]
	speaker_name.text = current_character_details["name"]
	current_visible_characters = 0
	dialog_line.text = line
	dialog_line.visible_characters = 0
	animate_text = true
	text_blip_timer.start()
	
func display_choices(choices: Array):
	# Clear any existing choices first
	for child in choice_list.get_children():
		child.queue_free()

	# Create a new button for each choice
	for choice in choices:
		var choice_button = ChoiceButtonScene.instantiate()
		choice_button.text = choice["text"]
		# Attach signal to button
		choice_button.pressed.connect(_on_choice_button_pressed.bind(choice["goto"]))
		# Add the button to the choices container
		choice_list.add_child(choice_button)
		
	# Show the choice list
	choice_list.show()
	
func skip_text_animation():
	dialog_line.visible_ratio = 1
	
func _on_text_blip_timeout():
	text_blip_sound.play_sound(current_character_details)
	
func _on_sentence_pause_timeout():
	text_blip_timer.start()
	
func _on_choice_button_pressed(anchor: String):
	choice_selected.emit(anchor)
	choice_list.hide()
