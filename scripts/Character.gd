class_name Character
extends Node

enum Name {
	APOLLO,
	PHOENIX,
	TRUCY
}

const CHARACTER_DETAILS : Dictionary = {
	Name.APOLLO: {
		"name": "Apollo",
		"gender": "male",
		"sprite_frames": null
	},
	Name.PHOENIX: {
		"name": "Phoenix",
		"gender": "male",
		"sprite_frames": preload("res://resources/phoenix_sprites.tres")
	},
	Name.TRUCY: {
		"name": "Trucy",
		"gender": "female",
		"sprite_frames": preload("res://resources/trucy_sprites.tres")
	}
}

static func get_enum_from_string(string_value: String) -> int:
	var upper_string = string_value.to_upper()
	if Name.has(upper_string):
		return Name[upper_string]
	else:
		push_error("Invalid Character name: " + string_value)
		return -1 # Or any other value to indicate an error
