class_name GemSpecialEffect extends SpecialEffect

# Player will receive extra gems at game's end
var number_of_gems := 1

func _init() -> void:
    id = 7
    color = Color.GOLD
    duration = 2
    name = "GEM"
    icon = Sprites.GEM_ICON

    
func execute(gm: GameManager, pos: Vector2i) -> void:
    super(gm, pos)    
    gm.add_gems(number_of_gems)
