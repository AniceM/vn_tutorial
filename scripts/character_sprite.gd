extends Node2D

@onready var animated_sprite = $AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
func change_character(character_name : Character.Name, is_talking : bool = true):
	var sprite_frames = Character.CHARACTER_DETAILS[character_name]["sprite_frames"]
	if sprite_frames:
		animated_sprite.sprite_frames = sprite_frames
		if is_talking:
			animated_sprite.play("talking") 
		else:
			animated_sprite.play("idle")
	else:
		animated_sprite.play("idle")
			
func play_idle_animation():
	animated_sprite.play("idle")
