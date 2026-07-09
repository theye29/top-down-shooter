extends CharacterBody2D

signal died(value)
var player
@export var zombie_damage = 1
@export var speed = 100
@export var hp = 1
@export var knockback_hit = 200
@export var knockback_self = 100
@export var value = 2

@onready var hitbox = $Hitbox
var attack_cooldown = false
var knockback_velocity = Vector2.ZERO



func _ready() -> void:
	hitbox.body_entered.connect(hit_human)
	pass 


func _process(delta: float) -> void:
	_move(delta)
	
func _move(delta) -> void :
	if knockback_velocity != Vector2.ZERO:
		velocity = knockback_velocity
		knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, knockback_self * delta)
	else:	
		var playerDirection = player.global_position - global_position
		look_at(player.global_position)
		if player.visible:
			rotation += deg_to_rad(180)
			velocity = playerDirection.normalized() * speed
		else:
			velocity = playerDirection.normalized() * -speed
	pass
	
	move_and_slide()


	pass

func take_damage(dmg):
	hp -= dmg
	if hp < 1:
		die()
	pass
	
func hit_human(body) -> void:

	if body.is_in_group("human") and not attack_cooldown:
		attack_cooldown = true
		var direction = (self.global_position - body.global_position).normalized()
		var player_direction = (body.global_position - self.global_position).normalized()
		knockback_apply(direction)
		body.knockback_power = knockback_hit
		body.knockback_apply(player_direction)
		body.take_damage(zombie_damage)
		await get_tree().create_timer(0.05).timeout
		player.bite_sound.play()
		attack_cooldown = false

func knockback_apply(direction):
	knockback_velocity = direction * knockback_self
	


func die():
	emit_signal("died", value)
	var death_sounds = [
		$ZombieDeath1,
		$ZombieDeath2
	]
	var sound = death_sounds[randi() % death_sounds.size()]
	sound.get_parent().remove_child(sound)
	get_tree().root.add_child(sound)
	sound.play()
	
	modulate = Color(1, 0.2, 0.2, 0.2)
	await get_tree().create_timer(0.1).timeout
	queue_free()
	pass
