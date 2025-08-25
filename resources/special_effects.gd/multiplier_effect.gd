class_name MultiplierSpecialEffect extends SpecialEffect

@export var multiplier := 2


func _init() -> void:
    color = Color.GREEN
    duration = 5
    name = "MULT"


func execute(gm: GameManager, pos: Vector2i) -> void:
    super(gm, pos)
    gm.update_points_multiplier(multiplier, duration)


func expire(gm: GameManager) -> void:
    super(gm)
    gm.reset_points_multiplier()
