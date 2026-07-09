extends Node2D

var joystick

@export var bullet : PackedScene
@export var damage = 100
var speed

var piercing = 1

var reload = false
var fire_cooldown = false

var fire_time = 0.0
@export var fire_rate = 0.5

var reload_current = 0.0
@export var reload_time = 2
var reload_sound = false
#Current bullet count before reload
var bullet_count = 0
#Max bullets per reload
@export var bullet_max_count = 6
#Max bullets on weapon
@export var bullet_limit = -1
#Total bullets on weapon
var bullet_total = 0

var line_time = 0.0
var line_duration = 0.01

@onready var player = get_parent()
@onready var bullet_line = get_tree().root.get_node("Game/BulletLine")
@onready var ammo_count = get_tree().root.get_node("Game/CanvasLayer/HudSelf/AmmoCount")

var can_shoot = true

func _ready() -> void:
	joystick = player.joystick_right
	speed = player.speed
	bullet_count = bullet_max_count
	if bullet_limit < 0:
		bullet_total = -1
		ammo_count.text = "x " + str(bullet_count) + " / ∞"
	else:
		bullet_total = bullet_limit
		ammo_count.text = "x " + str(bullet_count) + " / " + str(bullet_total)
	pass 


func _process(delta: float) -> void:
	if player.is_alive and can_shoot:
		_shoot(delta)
		if bullet_line.visible:
			await get_tree().process_frame
			await get_tree().process_frame
			bullet_line.visible = false
	pass
	
func _shoot(delta) -> void:
	var shoot_input = false
	
	if Input.is_mouse_button_pressed(MouseButton.MOUSE_BUTTON_LEFT):
		shoot_input = true
		
	if joystick and joystick.is_pressed:
		if joystick.output.length() > 0.5:
			shoot_input = true


	if ((shoot_input) and (bullet_count > 0) and !reload):
		player.speed = speed/player.walkspeed
		if !fire_cooldown:
			var b = bullet.instantiate()
			get_tree().current_scene.add_child(b)
			b.global_position = $Muzzle.global_position
			b.rotation = global_rotation
			fire_cooldown = true;
			b.weapon = self
			shot_sound()

			bullet_count -= 1
			if bullet_total == -1:
				ammo_count.text = "x " + str(bullet_count) + " / ∞"
			else:
				ammo_count.text = "x " + str(bullet_count) + " / " + str(bullet_total)
			if bullet_count == 0 and bullet_total != 0 and not reload:
				reload = true
	else:
		player.speed = speed
	if (Input.is_action_just_pressed("reload") and not reload):
		reload = true
		
	if (fire_cooldown):
		fire_time += delta
		
		if fire_time >= fire_rate:
			fire_cooldown = false
			fire_time = 0.0
	if reload:
		reload_weapon(delta)

func reload_weapon(delta):
	if bullet_total == 0:
		reload = false
		return
	ammo_count.text = "x RELOADING" 
	if !reload_sound and reload_time != 0:
		$ReloadSound.pitch_scale = 1.6
		$ReloadSound.play()
		reload_sound = true
	reload_current += delta

	if reload_current >= reload_time:
		var needed = bullet_max_count - bullet_count
		var to_reload = min(needed, bullet_total)
		if bullet_total == -1:
			bullet_count = bullet_max_count
			ammo_count.text = "x " + str(bullet_count) + " / ∞"

		else:
			bullet_count += to_reload
			bullet_total -= to_reload
			ammo_count.text = "x " + str(bullet_count) + " / " + str(bullet_total)
		
		$ReloadSound.stop()
		reload = false
		reload_sound = false
		reload_current = 0.0
	


func show_bullet(hitpoint):
	var hitstart = $Muzzle.global_position
	bullet_line.points = [bullet_line.to_local(hitstart), bullet_line.to_local(hitpoint)]
	bullet_line.width = 12.0
	var gradient = Gradient.new()
	
	gradient.set_color(0, Color(1, 1, 0))
	gradient.set_color(1, Color(1, 1, 0, 0))
	bullet_line.material = CanvasItemMaterial.new()
	bullet_line.material.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	bullet_line.gradient = gradient
	bullet_line.visible = true

func shot_sound():
	var sfx_shot = $GunshotSound.duplicate() 
	add_child(sfx_shot)
	sfx_shot.play()
	pass
