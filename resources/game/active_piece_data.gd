class_name ActivePieceData extends Resource

@export var piece_type: PieceSpawnData.PieceType
@export var position: Vector2i
@export var color: bool  # true = white


func serialize() -> Dictionary:
    return {
        "piece_type": piece_type,
        "position": {
            "x": position.x,
            "y": position.y,
        },
        "color": color,
    }


func deserialize(data: Dictionary) -> void:
    piece_type = data["piece_type"]
    position = Vector2i(data["position"]["x"], data["position"]["y"])
    color = data["color"]
