class_name BombSpecialEffect extends SpecialEffect

# Pieces around this one are destroyed

func _init() -> void:
    id = 2
    color = Color.BLUE_VIOLET
    duration = 1
    name = "BOMB"
    icon = Sprites.BOMB_ICON


func execute(gm: GameManager, pos: Vector2i) -> void:
    super(gm, pos)

    # Explodes and destroys all surrounding pieces
    var directions = [
        Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1),
        Vector2i(1, 1), Vector2i(1, -1), Vector2i(-1, 1), Vector2i(-1, -1)
    ]
    for direction in directions:
        var current_pos = pos + direction
        # Destroy the piece, score
        gm.destroy_at_position(current_pos, true)
