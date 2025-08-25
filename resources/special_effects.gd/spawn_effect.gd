class_name SpawnSpecialEffect extends SpecialEffect


func _init() -> void:
    color = Color.BLUE
    name = "SPAWN"
    icon = Sprites.SPAWN_ICON


func execute(gm: GameManager, pos: Vector2i) -> void:
    super(gm, pos)
    gm.spawn_new_piece()
