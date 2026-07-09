extends RayCast2D



var weapon
var bullet_damage
@export var hit_particle : PackedScene
func _ready() -> void:
	pass 

func _process(_delta: float) -> void:

	shoot()

	
func shoot() -> void:

	var bullet_start = global_position
	var bullet_end = global_position + -transform.x * 300
	var bullet_piercing = weapon.piercing
	bullet_damage = weapon.damage
	
	var space_state = get_world_2d().direct_space_state
	var hits = 0

	var hit_enemies = []
	
	while true:
		var query = PhysicsRayQueryParameters2D.create(bullet_start, bullet_end)
		query.exclude = [self]
		query.collision_mask = 1
		
		var result = space_state.intersect_ray(query)
		
		if not result:
			break
		
		var collider = result.collider
		var hit_pos = result.position


		if collider.is_in_group("wall"):
			bullet_end = hit_pos
			break
		
		if collider in hit_enemies:
			bullet_start = hit_pos + (-transform.x * 0.01)
			continue
		if collider.is_in_group("zombie"):
			
			collider.take_damage(bullet_damage)
			spawn_impact(hit_pos, result.normal)
			if collider in hit_enemies:
				bullet_start = hit_pos + (-transform.x * 0.01)
				continue
				
			hit_enemies.append(collider)
			hits += 1
			if hits >= bullet_piercing:
				bullet_end = hit_pos
				break
		

		bullet_start = hit_pos + (-transform.x * 0.01)

	weapon.show_bullet(bullet_end)
	queue_free()
	
func spawn_impact(pos, normal):
	var impact = hit_particle.instantiate()
	impact.global_position = pos
	impact.rotation = normal.angle()
	get_tree().current_scene.add_child(impact)
	var sfx_impact = $BulletImpact.duplicate() 
	get_tree().current_scene.add_child(sfx_impact)
	sfx_impact.global_position = pos
	sfx_impact.pitch_scale = 1.5
	sfx_impact.play()
	impact.get_node("GPUParticles2D").emitting = true
	await sfx_impact.finished
	sfx_impact.queue_free()
