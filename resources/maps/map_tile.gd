class_name MapTile extends Resource

@export var position: Vector2i
@export var is_active: bool = true  # false means the tile is blacked out/disabled


func _init(pos: Vector2i = Vector2i.ZERO, active: bool = true):
    position = pos
    is_active = active
