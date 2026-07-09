extends Area2D
class_name SafeZone
signal player_enter_safezone
signal player_exit_safezone

@onready var wall_door: Sprite2D = $"../WallDown/Sprite2D"
@onready var door_colision : CollisionShape2D = $"../WallDown/CollisionShape2D"
@onready var shadow: Sprite2D = $"../ShadowZone"
func _ready() -> void:
	pass 

func _process(_delta: float) -> void:
	pass
	


func disable_wall():
	door_colision.disabled = true
	wall_door.visible = false
	shadow.visible = false
	
func enable_wall():
	door_colision.disabled = false
	wall_door.visible = true
	shadow.visible = true
	


func _player_entered(body):
	if body.is_in_group("human"):
		player_enter_safezone.emit()

func _player_exited(body):
	if body.is_in_group("human"):
		player_exit_safezone.emit()
