extends Node2D

@onready var character_sprite = %CharacterSprite
@onready var dialog_ui = %DialogUI
@onready var next_sentence_sound = %NextSentenceSound

var dialog_index : int = 0

var dialog_lines : Array = []

func _ready():
	# load dialog
	dialog_lines = load_dialog("res://resources/story/first_scene.json")
	# connect signals
	dialog_ui.text_animation_done.connect(_on_text_animation_done)
	dialog_ui.choice_selected.connect(_on_choice_selected)
	# Process first line of dialog.
	dialog_index = 0
	process_current_line()
	
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
	# Check if this is a goto command
	if line.has("goto"):
		dialog_index = get_anchor_position(line["goto"])
		process_current_line()
		return
		
	# Check if this is just an acnhor declaration (not displayable content)
	if line.has("anchor"):
		dialog_index += 1
		process_current_line()
		return
		
	if line.has("choices"):
		# Display choices
		dialog_ui.display_choices(line["choices"])
	else:
		# Reading the line of dialog
		var character_name = Character.get_enum_from_string(line["speaker"])
		dialog_ui.change_line(character_name, line["text"])
		character_sprite.change_character(character_name)
	
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
