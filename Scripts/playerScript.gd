extends CharacterBody2D


#mobile
@export var joystick_right : VirtualJoystick


@export var speed = 200
var walkspeed = 2.0
var hp = 100
@export var max_hp = 100

var shield = 0
@export var max_shield = 50

var damage_level = 1
var firerate_level = 1
var reload_level = 1
var walkspeed_level = 1
var piercing_level = 1
var ammo_level = 1

var is_alive = true
var time_alive = 0.0
var money = 100000000

@onready var healthbar = get_tree().root.get_node("Game/CanvasLayer/HudSelf/HealthBar")
@onready var shieldbar = get_tree().root.get_node("Game/CanvasLayer/HudSelf/ShieldBar")
@onready var money_count = get_tree().root.get_node("Game/CanvasLayer/HudSelf/MoneyCount")
@onready var camera = $Camera2D
@onready var weapon = $Weapon
@onready var bite_sound = $ZombieBite
var offset_strength := 50.0
var offset_smoothness = 7.0
var knockback_velocity = Vector2.ZERO
var knockback_power = 100


func _ready() -> void:
	healthbar.value = hp
	shieldbar.value = shield
	money_count.text = "$" + str(money)
	pass 


func _process(delta: float) -> void:
	_aim(delta)
	_move(delta)


func take_damage(dmg):
	var rect = $"../CanvasLayer/PlayerHit"
	rect.color.a = 0.5

	var tween = create_tween()
	tween.tween_property(rect, "color:a", 0.0, 0.15)
	if shield > 0:
		shield -= dmg
		shieldbar.value = shield
	else:
		hp -= dmg
		healthbar.value = hp
		if hp < 1:
			die()
	
func knockback_apply(direction):
	knockback_velocity = direction * knockback_power
	
func _aim(delta) -> void:

	if joystick_right and joystick_right.is_pressed:
		var dir = joystick_right.output
		
		if dir.length() > 0.2: 
			rotation = dir.angle() + deg_to_rad(180)
			
			var target_offset = dir * offset_strength
			camera.offset = camera.offset.lerp(target_offset, offset_smoothness * delta)
	

	else:
		var mousePos = get_global_mouse_position()
		var direction = (mousePos - global_position).normalized()
		
		var target_offset = direction * offset_strength
		camera.offset = camera.offset.lerp(target_offset, offset_smoothness * delta)
		
		look_at(mousePos)
		rotation += deg_to_rad(180)

func _move(delta) -> void:
	if knockback_velocity != Vector2.ZERO:
		velocity = knockback_velocity
		knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, 500 * delta)
	else:	
		var direction = Vector2.ZERO
		
		
		if (Input.is_action_pressed("ui_up")):
			direction.y -= 1;
		if (Input.is_action_pressed("ui_down")):
			direction.y += 1;
		if (Input.is_action_pressed("ui_left")):
			direction.x -= 1;
		if (Input.is_action_pressed("ui_right")):
			direction.x += 1;
		
		if direction != Vector2.ZERO:
			if not $Running.playing:
				$Running.play()
		else:
			$Running.stop()
		velocity = direction.normalized() * speed
	move_and_slide()


func die():
	time_alive = int(time_alive)
	var minutes = int(time_alive / 60)
	var seconds = int(time_alive % 60)
	$"../CanvasLayer/GameOverPanel/TimeAlive".text = "Time Alive : " + "%02d:%02d" % [minutes, seconds]
	visible = false
	set_process(false)
	is_alive = false
	pass
	
func get_upgrade_type(type):
	match type:
		"damage":
			return [weapon.damage, weapon.damage + 20]
		"firerate":
			return [weapon.fire_rate, snapped(weapon.fire_rate * 0.9, 0.01)]
		"reload":
			return [weapon.reload_time, weapon.reload_time - 0.15]
		"walkspeed":
			return [walkspeed, walkspeed - 0.15]
		"piercing":
			return [weapon.piercing, weapon.piercing + 1]
		"ammo":
			return [weapon.bullet_max_count, weapon.bullet_max_count + 2]
func upgrade_damage():
	damage_level += 1
	weapon.damage = get_upgrade_type("damage")[1]
func upgrade_firerate():
	firerate_level += 1
	weapon.fire_rate = get_upgrade_type("firerate")[1]
func upgrade_reload():
	reload_level += 1
	weapon.reload_time = get_upgrade_type("reload")[1]
func upgrade_walkspeed():
	walkspeed_level += 1
	walkspeed = get_upgrade_type("walkspeed")[1]
func upgrade_piercing():
	piercing_level += 1
	weapon.piercing = get_upgrade_type("piercing")[1]
func upgrade_ammo():
	ammo_level += 1
	weapon.bullet_max_count = get_upgrade_type("ammo")[1]
	weapon.bullet_count += 2
	weapon.ammo_count.text = "x " + str(weapon.bullet_count) + " / ∞"
