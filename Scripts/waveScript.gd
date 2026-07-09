extends Node2D

@export var enemy_zombie : PackedScene
@export var enemy_zombie_boss : PackedScene
@export var enemy_zombie_fast : PackedScene

@onready var player = $"../Player"
@onready var wave_label = $"../CanvasLayer/WaveCount"
@onready var arrow = $"../CanvasLayer/Arrow"
@onready var money_count = $"../CanvasLayer/HudSelf/MoneyCount"

var map_area
var map_size 
var map_center
var map_half_area 

var wave_number = 0
var enemies_spawned = 0
var enemies_tospawn = 0
var alive_enemies = 0
var enemies_killed = 0

var spawn_cooldown = 1.0
var spawn_timer = 0.0

var music_tween
var player_in_safezone = false
var wave_in_progress = false
#var time_between_waves = 3.0
#var wave_timer = 0.0

@onready var safezone : SafeZone = get_node("../Map/Safezone/AreaSafezone")
var safezone_position
@onready var screen_size = get_viewport_rect().size


func _ready() -> void:
	safezone_position = safezone.global_position
	crossfade(false)

	map_area = $"../Map/MapArea/CollisionShape2D".shape
	map_size = map_area.size
	map_center = $"../Map/MapArea".global_position
	map_half_area = map_size / 2
	
	safezone.player_enter_safezone.connect(_on_enter_safezone)
	safezone.player_exit_safezone.connect(_on_exit_safezone)
	await get_tree().process_frame
	safezone.disable_wall()
	 



func _process(delta: float) -> void:
	if wave_in_progress:
		wave_spawning(delta)
		player.time_alive += delta
	else:
		wave_interval()
	pass
	


func crossfade(to_combat: bool):
	if music_tween:
		music_tween.kill()

	var from = $SongCalm if to_combat else $SongBattle
	var to = $SongBattle if to_combat else $SongCalm

	if not to.playing:
		to.volume_db = -30
		to.play()

	music_tween = create_tween()
	music_tween.tween_property(from, "volume_db", -30, 0.5)
	music_tween.tween_property(to, "volume_db", -15, 0.5)
	music_tween.tween_callback(from.stop)
func start_wave():
	crossfade(true)
	wave_label.text = "WAVE : " + str(wave_number)
	enemies_spawned = 0
	alive_enemies = 0
	enemies_tospawn = 5 + wave_number * 3
	spawn_cooldown = 0.0 - wave_number * 0.05
	if spawn_cooldown < 0.2:
		spawn_cooldown = 0.2
	pass
	wave_in_progress = true


func wave_spawning(delta):
	spawn_timer += delta
	
	if enemies_spawned < enemies_tospawn:
		if spawn_timer >= spawn_cooldown:
			spawn_enemy()
			enemies_spawned += 1
			alive_enemies += 1
			spawn_timer = 0
	if enemies_spawned == enemies_tospawn and alive_enemies == 0:
		end_wave()


func spawn_enemy():
	var enemies = [
		enemy_zombie.instantiate(),
		enemy_zombie_boss.instantiate(),
		enemy_zombie_fast.instantiate()
		]
	var enemy
	var fast_chance = min(wave_number * 5, 40) # aumenta com wave
	var rand = randi() % 100

	if enemies_spawned % 15 == 0 and enemies_spawned != 0:
		enemy = enemies[1]

	elif rand < fast_chance and wave_number > 2:
		enemy = enemies[2]

	else:
		enemy = enemies[0]
	enemy.player = player
	enemy.connect("died", Callable(self, "_on_enemy_died"))
	enemy.global_position = spawn_position(enemy.scale.x)
	while enemy.global_position.distance_to(safezone.global_position) < 400:
		enemy.global_position = spawn_position(enemy.scale.x)
	add_child(enemy)
	


func spawn_position(enemy_size):
	var margin = 300 + enemy_size
	var screen_side = randi() % 4

	match screen_side:
		0:
			return map_center + Vector2(-map_half_area.x - margin, randf_range(-map_half_area.y, map_half_area.y))
		1:
			return map_center + Vector2(map_half_area.x + margin, randf_range(-map_half_area.y, map_half_area.y))
		2:
			return map_center + Vector2(randf_range(-map_half_area.x, map_half_area.x), -map_half_area.y - margin)
		3:
			return map_center + Vector2(randf_range(-map_half_area.x, map_half_area.x), map_half_area.y + margin)
		
	


func wave_interval():
	wave_label.text = ""
	var camera_pos = player.global_position
	var dir = (safezone_position - camera_pos).normalized()
	var center = screen_size / 2

	arrow.position = center + dir * 100
	arrow.rotation = dir.angle() + deg_to_rad(90)
	
	var safezone_offset = safezone.global_position - camera_pos
	var is_offscreen = (
	abs(safezone_offset.x) > screen_size.x / 2 or
	abs(safezone_offset.y) > screen_size.y / 2
)

	arrow.visible = is_offscreen
	


func _on_enter_safezone():
	player_in_safezone = true
	


func _on_exit_safezone():
	if !wave_in_progress:
		safezone.call_deferred("enable_wall")
		if player_in_safezone:
			wave_number += 1
			start_wave()
	player_in_safezone = false


func _on_enemy_died(value):
	alive_enemies -= 1
	player.money += value
	money_count.text = "$" + str(player.money)
	enemies_killed += 1
	$"../CanvasLayer/GameOverPanel/EnemiesKilled".text = "Enemies Killed : " + str(enemies_killed)

func end_wave():
	crossfade(false)
	safezone.disable_wall()
	wave_in_progress = false
	$"../CanvasLayer/GameOverPanel/WavesBeaten".text = "Waves Beaten : " + str(wave_number)
	# wave_timer = 0
