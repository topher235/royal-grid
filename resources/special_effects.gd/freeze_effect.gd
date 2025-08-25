class_name FreezeSpecialEffect extends SpecialEffect

# Piece cannot move for X (duration) turns
@export var freeze_duration := 3

func _init() -> void:
    color = Color.VIOLET
    duration = 2
    name = "FRZ"


func execute(gm: GameManager, pos: Vector2i) -> void:
    super(gm, pos)

    # set a flag on the piece or tile that stops it from being selectable
    # use freeze_duration to make it the freeze go away
    # flag can be an int field then if field > 0, the piece is frozen
    gm.freeze_tile(pos, freeze_duration)
