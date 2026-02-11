extends Node2D
@onready var patrick: CharacterBody2D = $"../Patrick"
@onready var jeffery: CharacterBody2D = $"../Jeffery"
@onready var player: CharacterBody2D = $"../player"

var phase = 1
func _ready() -> void:
	jeffery.hider()
	await get_tree().create_timer(1).timeout
	
	patrick.can_attack = true
func _process(dt):
	
	if patrick.health < 150 and phase ==1:
		phase = 1.5
		patrick.hider()
		jeffery.hider()
		patrick.position = Vector2(500,500)
		jeffery.position = Vector2(500,500)
		await get_tree().create_timer(2).timeout
		phase = 2
		patrick.can_attack = true
		jeffery.can_attack = true
		patrick.shower()
		jeffery.shower()
	if patrick.can_attack and phase ==1:
		patrick.can_attack = false
		await get_tree().create_timer(0.25).timeout
		
		var t = randi_range(1,4)
		if t == 1:
			patrick.shower()
			var d = player.position.x/abs(player.position.x)
			if d == 0:
				d = 1
			patrick.dash(d,0.8)
		elif t == 2:
			patrick.shower()
			patrick.slash(randi_range(0,1)*2-1,0.6)
		elif t == 3:
			patrick.shower()
			patrick.dive(0.7)
		elif t ==4:
			patrick.hider()
			patrick.net()
			
	elif patrick.can_attack and jeffery.can_attack and phase == 2:
		print(jeffery.position)
		
		patrick.can_attack = false
		jeffery.can_attack = false
		await get_tree().create_timer(0.25).timeout
		var t = randi_range(1,8)
		if t == 1:
			patrick.shower()
			patrick.dive(0.7)
			
			await get_tree().create_timer(1.2).timeout
			jeffery.shower()
			jeffery.dive(0.7)
			
		elif t ==2:
			var d = randi_range(0,1)*2-1
			patrick.shower()
			patrick.dash(d,0.8)
			
			await get_tree().create_timer(1.3).timeout
			jeffery.shower()
			jeffery.dash(d,0.8)
			
		elif t ==3:
			jeffery.shower()
			patrick.shower()
			jeffery.dash(1,0.8)
			patrick.dash(-1,0.8)
		elif t ==4:
			jeffery.shower()
			patrick.shower()
			jeffery.dash(player.position.x/abs(player.position.x),0.8)
			patrick.dive(0.7)
		elif t == 5:
			jeffery.shower()
			patrick.shower()
			jeffery.slash(1,0.6)
			patrick.slash(-1,0.6)
		elif t ==6 or t == 9:
			jeffery.hider()
			patrick.hider()
			jeffery.net()
			await get_tree().create_timer(2).timeout
			patrick.net()
		elif t == 7:
			jeffery.shower()
			patrick.shower()
			var d =player.position.x/abs(player.position.x)
			jeffery.slash(d,1)
			patrick.dash(-d,0.8)
		elif t == 8:
			jeffery.shower()
			patrick.shower()
			var d =randi_range(0,1)*2-1
			jeffery.slash(d,0.6)
			patrick.dive(0.7)
		

			

	
