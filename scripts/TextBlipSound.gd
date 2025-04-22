extends AudioStreamPlayer

const sounds : Dictionary = {
	"male": preload("res://assets/sounds/sfx-blipmale.wav"),
	"female": preload("res://assets/sounds/sfx-blipfemale.wav")
}

func play_sound(character_details: Dictionary):
	var character_gender = character_details["gender"]
	stream = sounds[character_gender]
	play()
