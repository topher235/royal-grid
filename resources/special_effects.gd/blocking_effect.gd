class_name BlockingSpecialEffect extends SpecialEffect


func _init() -> void:
    duration = 2
    can_piece_move_to = false
    color = Color.RED
    name = "BLOCK"


func execute(gm: GameManager, pos: Vector2i) -> void:
    super(gm, pos)
    pass


func expire(gm: GameManager) -> void:
    super(gm)
    # gm.remove_effect(self)
