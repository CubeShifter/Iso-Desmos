extends CharacterBody2D


const SPEED = 80
const JUMP_VELOCITY = -256
const GRAVITY = 512
const DASH_LENGTH = 256



var dashing:= false
var direction:= 1
var can_dash := true
var dash_refillable := false
var can_attack := true
var has_control := true
var attack_direction := ""
var health := 5
var healing := false
var mana = 0
var vampiring = false
var vampired_times = 0
const max_health =5
@onready var shader: ColorRect = $"../CanvasLayer/ColorRect"
@onready var heal: Timer = $Timers/Heal
@onready var mana_rect: ColorRect = $CanvasLayer/Mana
@onready var dashing_timer: Timer = $"Timers/Dashing"
@onready var dash_cooldown: Timer = $"Timers/Dash Cooldown"
@onready var attack: Area2D = $Attack
@onready var attack_timer: Timer = $Timers/Attack
@onready var attack_cooldown: Timer = $"Timers/Attack Cooldown"
@onready var control_regain: Timer = $"Timers/Control Regain"
@onready var hit_iframes: Timer = $"Timers/Hit Iframes"
@onready var hit_detector: Area2D = $"Hit Detector"
@onready var health_bar: HBoxContainer = $"CanvasLayer/Health Bar"
@onready var vampire: Timer = $Timers/Vampire
@onready var sprite: AnimatedSprite2D = $Sprite

const HEALTH = preload("res://Scenes/health.tscn")
func _ready() -> void:
	update_mana(0)
	update_health(max_health)
func _physics_process(delta: float) -> void:
	# Add the gravity.
	health = min(health,max_health)
	if velocity.x>0:
		sprite.flip_h = false
	elif velocity.x<0:
		sprite.flip_h = true
	if health == 0:
		get_tree().reload_current_scene()
	if not is_on_floor() and not healing:
		velocity.y += GRAVITY * delta
	
	else:
		if dash_refillable:
			can_dash = true
	if is_on_floor() and not dashing:
		pass
	if Input.is_action_just_pressed("heal") and not healing and mana >8:
		mana -=9
		update_mana(mana)
		velocity = Vector2.ZERO
		healing = true
		has_control =false
		heal.start()
		vampired_times = 0
	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor() and has_control:
		sprite.play("Jump")
		dashing = false
		velocity.y = JUMP_VELOCITY	
	elif Input.is_action_just_released("jump") and velocity.y <0 and has_control:
		velocity.y = 0
	elif Input.is_action_just_pressed("dash") and can_dash and has_control:
		sprite.play("Dash")
		dashing = true
		can_dash = false
		dash_refillable = false
		dash_cooldown.start()
		dashing_timer.start()

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	
	
	if Input.is_action_pressed("left") and not dashing and has_control:
		if is_on_floor():
			sprite.play("Walk")
		velocity.x = -SPEED
		direction = -1
	elif Input.is_action_pressed("right") and not dashing and has_control:
		if is_on_floor():
			sprite.play("Walk")
		velocity.x = SPEED
		direction =1
	elif is_on_floor():
		print(delta)
		
		if is_on_floor() and not dashing and not healing:
			sprite.play("Idle")
		velocity.x*= 0.8
	else:
		velocity.x *= 0.7
		
	if dashing:
		velocity =Vector2(direction*DASH_LENGTH,0)
		
	if Input.is_action_just_pressed("attack") and can_attack and has_control:
		attack.get_node("Collision").set_deferred("disabled",false)
		attack.visible = true
		can_attack = false
		attack_timer.start()
		attack_cooldown.start()
		if Input.is_action_pressed("up"):
			attack.position = Vector2(-6,-28)
			attack.rotation = 0
			attack_direction = "UP"
		elif Input.is_action_pressed("down") and not is_on_floor():
			attack.position = Vector2(6,28)
			attack.rotation =  deg_to_rad(180)
			attack_direction = "DOWN"
		else:
			
			
			if direction ==1:
				attack.rotation = deg_to_rad(90)
				attack_direction = "RIGHT"
				attack.position = Vector2(24,-5)
			else:
				attack.rotation = deg_to_rad(270)
				attack.position = Vector2(-24,5)
				attack_direction = "LEFT"
		print(attack.position)
	if healing:
		velocity = Vector2.ZERO
	move_and_slide()
func _on_dashing_timeout() -> void:
	dashing = false


func _on_dash_cooldown_timeout() -> void:
	dash_refillable = true


func _on_attack_timeout() -> void:
	attack.get_node("Collision").set_deferred("disabled",true)
	attack.visible = false


func _on_attack_cooldown_timeout() -> void:
	can_attack = true






func _on_control_regain_timeout() -> void:
	has_control = true


func _on_hit_iframes_timeout() -> void:
	hit_detector.get_node("Collision").set_deferred("disabled",false)
	
func _on_hit_detector_area_entered(area: Area2D) -> void:
	vampiring = false
	shader.material.set_shader_parameter("enabled", false)
	hit_detector.get_node("Collision").set_deferred("disabled",true)
	velocity = Vector2(-600*direction,-120)
	dashing = false
	healing = false
	has_control = false
	control_regain.start()
	hit_iframes.start()
	health -= 1
	update_health(health)
func hit():
	mana = min(mana+1,9)
	update_mana(mana)
	if vampiring and vampired_times< 2:
		vampired_times+=1
		health = min(health+1,max_health)
		update_health(health)
	if not has_control:
		pass
	elif attack_direction == "DOWN":
		velocity = Vector2(0,-150)
	elif attack_direction == "LEFT":
		velocity = Vector2(100,0)
	elif attack_direction == "RIGHT":
		velocity = Vector2(-100,0)
	
func update_health(h):
	for i in health_bar.get_children():
		i.queue_free()
	for i in range(h):
		var hubba = HEALTH.instantiate()
		
		health_bar.add_child(hubba)
	
func update_mana(m):
	mana_rect.size.x = 20*m



func _on_heal_timeout() -> void:
	if healing:
		shader.material.set_shader_parameter("enabled", true)
		has_control  =true
		healing = false
		vampiring = true
		vampire.start()


func _on_vampire_timeout() -> void:
	vampiring = false
	shader.material.set_shader_parameter("enabled", false)
