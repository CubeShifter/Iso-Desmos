extends CharacterBody2D
enum STATES {DASHING,WAITING,SLASHING,PREDIVE,DIVING}
var state = STATES.WAITING
@onready var collision: CollisionShape2D = $Collision
const SHOCKWAVE = preload("res://Scenes/shockwave.tscn")
@onready var projectiles: Node2D = $"../Projectiles"
const SLASH = preload("res://Scenes/slash.tscn")
var direction = 1
var can_attack = false
@onready var player: CharacterBody2D = $"../player"
@onready var hollision: CollisionShape2D = $"Hit Detector/CollisionShape2D"
@onready var pollision: CollisionShape2D = $Hurtbox/CollisionShape2D
var slelay := 1.0
@export var health = 200
@onready var sprite: AnimatedSprite2D = $Sprite
@onready var flash: Timer = $Flash

	
	
func _ready() -> void:
	hider()
	

func _physics_process(dt):
	if velocity.x>0:
		sprite.flip_h = false
	elif velocity.x<0:
		sprite.flip_h = true
	
	if state == STATES.DASHING and (position.x >128 or position.x < -128):
		velocity.x = 0
		state =STATES.WAITING
		await get_tree().create_timer(0.6).timeout
		can_attack = true
		hider()
	elif state ==STATES.SLASHING and position.y>120:
		collision.set_deferred("disabled",false)
		state = STATES.WAITING
		velocity = Vector2.ZERO
		can_attack = true
		
		
	elif state== STATES.PREDIVE:
		position.x -= min(100*dt,max(-100*dt,position.x-player.position.x))
	if state == STATES.DIVING and is_on_floor():
		state =STATES.WAITING
		var shock = SHOCKWAVE.instantiate()
		shock.position.x = self.position.x
		await get_tree().create_timer(0.1).timeout
		shock.position.y = 82
		projectiles.add_child(shock)
		await get_tree().create_timer(0.5).timeout
		can_attack = true
		hider()
		
	
		
	move_and_slide()
	
	

func dash(dir,delay):
	sprite.play("dash")
	if dir ==1:
		sprite.flip_h = false
	elif dir ==-1:
		sprite.flip_h = true
	shower()
	velocity = Vector2.ZERO
	can_attack =false
	position = Vector2(dir*-120,66)
	
	await get_tree().create_timer(delay).timeout
	state = STATES.DASHING
	velocity.x = 600*dir
	direction = dir
func slash(dir,delay):
	sprite.play("slash")
	if dir ==1:
		sprite.flip_h = false
	elif dir ==-1:
		sprite.flip_h = true
	collision.set_deferred("disabled",true)
	can_attack =false
	velocity = Vector2.ZERO
	position = Vector2(min(128,max(-128,player.position.x-128*dir)),-20)
	var ppos = player.position
	
	await get_tree().create_timer(delay).timeout
	state =STATES.SLASHING
	var velt = (ppos-position).normalized()*720
	velocity = velt
func dive(delay):
	sprite.play("dive")
	can_attack =false
	velocity = Vector2.ZERO
	position = Vector2(player.position.x,-64)
	state = STATES.PREDIVE
	await get_tree().create_timer(delay -0.3).timeout
	state = STATES.DIVING
	velocity = Vector2(0,0)
	await get_tree().create_timer(0.3).timeout
	velocity = Vector2(0,800)

	
func net():
	
	
	var h = range(-4,5)
	h.remove_at(randf_range(0,len(h)-1))
	var v = range(-1,2)
	for i in h:
		var s = SLASH.instantiate()
		s.position.x = 40* i
		projectiles.add_child(s)
	for i in v:
		var s = SLASH.instantiate()
		s.position.y = 50* i
		s.horizontal = true
		projectiles.add_child(s)
	await get_tree().create_timer(1.5).timeout
	can_attack = true
	
func hider():
	visible = false
	hollision.set_deferred("disabled",true)
	pollision.set_deferred("disabled",true)
	collision.set_deferred("disabled",true)
func shower():
	visible = true
	hollision.set_deferred("disabled",false)
	pollision.set_deferred("disabled",false)
	collision.set_deferred("disabled",false)
	

func _on_hit_detector_area_entered(area: Area2D) -> void:
	health -= 5
	sprite.material.set_shader_parameter("enabled", true)
	player.hit()
	flash.start()
	


func _on_flash_timeout() -> void:
	sprite.material.set_shader_parameter("enabled", false)
