class_name MultiplierSpecialEffect extends SpecialEffect

@export var multiplier := 2
@export var multiplier_duration := 5


func _init() -> void:
    color = Color.GREEN
    duration = 2
    name = "MULT"


func execute(gm: GameManager, pos: Vector2i) -> void:
    super(gm, pos)
    gm.update_points_multiplier(multiplier, multiplier_duration)


func expire(gm: GameManager) -> void:
    super(gm)
    gm.reset_points_multiplier()
