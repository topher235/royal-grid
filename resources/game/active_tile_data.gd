class_name ActiveTileData extends Resource

@export var position: Vector2i
@export var freeze_counter: int


func serialize() -> Dictionary:
    return {
        "position": {
            "x": position.x,
            "y": position.y,
        },
        "freeze_counter": freeze_counter,
    }


func deserialize(data: Dictionary) -> void:
    position = Vector2i(data["position"]["x"], data["position"]["y"])
    freeze_counter = data["freeze_counter"]
