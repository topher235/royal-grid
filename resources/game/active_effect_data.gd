class_name ActiveEffectData extends Resource

@export var effect_id: int
@export var position: Vector2i
@export var remaining_duration: int


func serialize() -> Dictionary:
    return {
        "effect_id": effect_id,
        "position": {
            "x": position.x,
            "y": position.y,
        },
        "remaining_duration": remaining_duration,
    }


func deserialize(data: Dictionary) -> void:
    effect_id = data["effect_id"]
    position = Vector2i(data["position"]["x"], data["position"]["y"])
    remaining_duration = data["remaining_duration"]
