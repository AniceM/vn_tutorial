extends Node2D

@onready var animated_sprite = $AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
func change_character(character_name: Character.Name, is_talking: bool, expression: String):
	var sprite_frames = Character.CHARACTER_DETAILS[character_name]["sprite_frames"]
	var stance = "talking" if is_talking else "idle"
	var animation_name = expression + "-" + stance if expression else stance
	
	# If the character has sprite frames, update animated_sprite and play the animation
	if sprite_frames:
		animated_sprite.sprite_frames = sprite_frames
		# Check if the associated expression animation exists.
		# If not, play the default (stance) animation.
		if animated_sprite.sprite_frames.has_animation(animation_name):
			animated_sprite.play(animation_name)
		else:
			animated_sprite.play(stance)
	else:
		# Switch to the idle animation of the character currently displayed
		play_idle_animation()

func play_idle_animation():
	var last_animation = animated_sprite.animation
	if last_animation and not last_animation.ends_with("-idle"):
		# If a custom expression is displayed, try to find matching idle animation
		# If it exists, play it. Otherwise, simply play the normal idle animation.
		var idle_expression = last_animation.replace("talking", "idle")
		if animated_sprite.sprite_frames.has_animation(idle_expression):
			animated_sprite.play(idle_expression)
		else:
			animated_sprite.play("idle")
