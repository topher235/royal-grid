class_name GameConfig extends Resource

@export var grid_size: Vector2i = Vector2i(5, 5)
@export var tile_size: int = 32
@export var starting_pieces: Array[PieceSpawnData] = []
@export var piece_spawn_rules: PieceSpawnRules
@export var game_rules: GameRules


func _init() -> void:
    if not piece_spawn_rules:
        piece_spawn_rules = PieceSpawnRules.new()
    if not game_rules:
        game_rules = GameRules.new()


static func default_game() -> GameConfig:
    var this = GameConfig.new()

    var white_pawn = PieceSpawnData.new()
    white_pawn.piece_type = PieceSpawnData.PieceType.BISHOP
    white_pawn.position = Vector2i(1, 4)
    white_pawn.color = true

    var black_pawn = PieceSpawnData.new()
    black_pawn.piece_type = PieceSpawnData.PieceType.KING
    black_pawn.position = Vector2i(2, 0)
    black_pawn.color = false

    var test_pieces: Array[PieceSpawnData] = [
        white_pawn,
        black_pawn,
    ]
    this.starting_pieces = test_pieces
    return this
