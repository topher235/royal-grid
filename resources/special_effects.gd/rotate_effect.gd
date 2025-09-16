class_name RotateSpecialEffect extends SpecialEffect

enum RotationDirection {
    CLOCKWISE,
    COUNTER_CLOCKWISE,
}
    
@export var rotation_direction: RotationDirection = RotationDirection.CLOCKWISE


func _init() -> void:
    id = 6
    color = Color.ORANGE
    duration = 1
    name = "ROT"
    icon = Sprites.MULT_ICON


func execute(gm: GameManager, pos: Vector2i) -> void:
    super(gm, pos)
    
    # Get the chess board from the game manager
    var chess_board = gm.chess_board
    if not chess_board:
        Log.error(self, "Chess board not found")
        return
    
    # Rotate the board
    await chess_board.rotate_board(rotation_direction)
