extends Node2D

@onready var background = %Background
@onready var character_sprite = %CharacterSprite
@onready var dialog_ui = %DialogUI
@onready var next_sentence_sound = %NextSentenceSound

var transition_effect: String = "fade"
var dialog_file: String = "res://resources/story/first_scene.json"
var dialog_index: int = 0
var dialog_lines: Array = []

func _ready():
	# load dialog
	dialog_lines = load_dialog(dialog_file)
	# connect signals
	dialog_ui.text_animation_done.connect(_on_text_animation_done)
	dialog_ui.choice_selected.connect(_on_choice_selected)
	SceneManager.transition_out_completed.connect(_on_transition_out_completed)
	SceneManager.transition_in_completed.connect(_on_transition_in_completed)
	# Reset some values
	dialog_index = 0
	# Start the scene
	SceneManager.transition_in()
	
func _input(event):
	var line = dialog_lines[dialog_index]
	var has_choices = line.has("choices")
	if event.is_action_pressed("next_line") and not has_choices:
		if dialog_ui.animate_text:
			dialog_ui.skip_text_animation()
		else:
			if dialog_index < len(dialog_lines) - 1:
				dialog_index += 1
				next_sentence_sound.play()
				process_current_line()
	
func process_current_line():
	var line = dialog_lines[dialog_index]

	# Check if this is the end of our scene
	if line.has("next_scene"):
		# Update data
		var next_scene = line["next_scene"]
		dialog_file = "res://resources/story/" + next_scene + ".json" if !next_scene.is_empty() else ""
		transition_effect = line.get("transition", "fade")
		# Transition out
		SceneManager.transition_out(transition_effect)
		return

	# Check if we need to change the scene
	if line.has("location"):
		# Change the background
		var background_file = "res://assets/images/" + line["location"] + ".png"
		background.texture = load(background_file)
		# Proceed to the next line without waiting for user input
		dialog_index += 1
		process_current_line()
		return

	# Check if this is a goto command
	if line.has("goto"):
		# Update dialog_index and immediately process the new line
		dialog_index = get_anchor_position(line["goto"])
		process_current_line()
		return
		
	# Check if this is just an acnhor declaration (not displayable content)
	if line.has("anchor"):
		# Proceed to the next line without waiting for user input
		dialog_index += 1
		process_current_line()
		return

	# Update character sprite accordingly, default to speaker if show_character is not present
	if line.has("show_character"):
		var character_name = Character.get_enum_from_string(line["show_character"])
		character_sprite.change_character(character_name, false, line.get("expression", ""))
	elif line.has("speaker"):
		var character_name = Character.get_enum_from_string(line["speaker"])
		character_sprite.change_character(character_name, true, line.get("expression", ""))
		
	if line.has("choices"):
		# Display choices
		dialog_ui.display_choices(line["choices"])
	elif line.has("text"):
		# Reading the line of dialog
		var speaker_name = Character.get_enum_from_string(line["speaker"])
		dialog_ui.change_line(speaker_name, line["text"])
	else:
		# No choice or line of dialog here
		# Which means we don't need to wait for user input
		dialog_index += 1
		process_current_line()
		return
	
func get_anchor_position(anchor: String):
	# Find the anchor entry with matching name
	for i in range(dialog_lines.size()):
		if dialog_lines[i].has("anchor") and dialog_lines[i]["anchor"] == anchor:
			return i
			
	# If we get here, the anchor wasn't found
	printerr("Error: Could not find anchor '" + anchor + "'")
	return null
	
func load_dialog(file_path):
	# Check if the file exists
	if not FileAccess.file_exists(file_path):
		printerr("Error: File does not exist: ", file_path)
		return null
		
	# Open the file
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		printerr("Error: Failed to open file: ", file_path)
		return null
	
	# Read the content as text
	var content = file.get_as_text()
	
	# Parse the JSON
	var json_content = JSON.parse_string(content)
	
	# Check if parsing was successful
	if json_content == null:
		printerr("Error: Failed to parse JSON from file: ", file_path)
		return null
	
	# Return the dialog
	return json_content

func _on_text_animation_done():
	character_sprite.play_idle_animation()
	
func _on_choice_selected(anchor: String):
	dialog_index = get_anchor_position(anchor)
	process_current_line()
	next_sentence_sound.play()

func _on_transition_out_completed():
	# Load new dialog (if it exists)
	if !dialog_file.is_empty():
		dialog_lines = load_dialog(dialog_file)
		dialog_index = 0
		var first_line = dialog_lines[dialog_index]
		# Process first line ahead if it has location info
		if first_line.has("location"):
			background.texture = load("res://assets/images/" + first_line["location"] + ".png")
			# -> You can add all the pre-processing code needed here, such as the music <-
			dialog_index += 1
		# Now that we are done preparing the next scene, call SceneManager again
		SceneManager.transition_in(transition_effect)
	else:
		# Presumably the end of the game; you can do what you want here.
		print("End")

func _on_transition_in_completed():
	# Start processing dialog
	process_current_line()
