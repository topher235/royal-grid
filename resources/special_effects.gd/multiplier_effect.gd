class_name MultiplierSpecialEffect extends SpecialEffect

@export var multiplier := 1
@export var multiplier_duration := 5


func _init() -> void:
    id = 4
    color = Color.GREEN
    duration = 2
    name = "MULT"
    icon = Sprites.MULT_ICON


func execute(gm: GameManager, pos: Vector2i) -> void:
    super(gm, pos)
    gm.update_effects_mult(multiplier, multiplier_duration)


func expire(gm: GameManager) -> void:
    super(gm)
#    gm.reset_points_multiplier()
