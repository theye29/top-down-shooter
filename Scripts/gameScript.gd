extends Node2D


var enemy_spawn = 0.5
var enemy_timer = 0.0
var enemy_boss_timer = 0.0
var enemy_boss_tlimit = 0.5
@onready var player = $Player
@onready var spawn_pos = get_node("Map/PlayerSpawn")
func _ready() -> void:
	player.global_position =  spawn_pos.global_position
	player.camera.global_position = spawn_pos.global_position
	player.camera.reset_smoothing()
	if not OS.has_feature("mobile"):
		$CanvasLayer/VirtualJoystickLeft.visible = false
		$CanvasLayer/VirtualJoystickRight.visible = false
		$CanvasLayer/ReloadButton.visible = false
		
		$CanvasLayer/VirtualJoystickLeft.mouse_filter = Control.MOUSE_FILTER_IGNORE
		$CanvasLayer/VirtualJoystickRight.mouse_filter = Control.MOUSE_FILTER_IGNORE
		$CanvasLayer/ReloadButton.mouse_filter = Control.MOUSE_FILTER_IGNORE
func _process(_delta: float) -> void:
	if player.is_alive:
		pass
	else:
		$CanvasLayer/GameOverPanel.visible = true
		$CanvasLayer/Restart.visible = true
		$CanvasLayer/WaveCount.visible = false
		$CanvasLayer/HudSelf.visible = false
		
	pass


func _on_restart_pressed() -> void:
	get_tree().reload_current_scene()
	$CanvasLayer/WaveCount.visible = true
	pass 
