class_name SpawnSpecialEffect extends SpecialEffect


func _init() -> void:
    id = 5
    color = Color.BLUE
    name = "SPAWN"
    icon = Sprites.SPAWN_ICON


func execute(gm: GameManager, pos: Vector2i) -> void:
    """
    50% chance a queen is spawned
    50% chance the piece is white
    """
    super(gm, pos)
    
    var is_new_piece_queen = randf() < 0.5
    var piece_type = PieceSpawnData.PieceType.QUEEN if is_new_piece_queen else PieceSpawnData.PieceType.KING
    
    var piece_data = PieceSpawnData.new()
    piece_data.color = randf() < 0.5
    piece_data.piece_type = piece_type
    
    gm.spawn_new_piece_from_data(piece_data, [pos])
