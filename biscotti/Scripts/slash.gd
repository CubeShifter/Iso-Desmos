extends Area2D
@onready var line_2d: Line2D = $Line2D
@export var horizontal = false
@onready var collision: CollisionShape2D = $CollisionShape2D

var delay = 1.25

# Called when the node enters the scene tree for the first time.	 
func _ready() -> void:
	
	if not horizontal:
		rotation = randf_range(0.80	*PI,1.20*PI)
	else:
		rotation = [randf_range(1.58*PI,1.6*PI),randf_range(1.42*PI,1.40*PI)].pick_random()
	await get_tree().create_timer(delay).timeout
	collision.set_deferred("disabled",false)
	line_2d.default_color = Color8(128,128,164)
	await get_tree().create_timer(0.25).timeout
	queue_free()
	
		
	


	
# Called every frame. 'delta' is the elapsed time since the previous frame
