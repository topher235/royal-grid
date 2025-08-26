class_name GameState extends Resource

@export var config: GameConfig
@export var current_turn := true  # true = white, false = black
@export var turn_number := 1
@export var pieces_on_board: Array[Array] = []
@export var captured_pieces: Array[PieceSpawnData] = []
@export var last_move: MoveData
@export var game_phase: GamePhase = GamePhase.SETUP

var score: int

enum GamePhase {SETUP, PLAYING, GAME_OVER}


func _init() -> void:
    if not config:
        config = GameConfig.new()
    
    for x in range(config.grid_size.x):
        pieces_on_board[x] = []
        for y in range(config.grid_size.y):
            pieces_on_board[x][y] = null


func add_piece(piece_data: PieceSpawnData):
    pieces_on_board[piece_data.position.x][piece_data.position.y] = piece_data


func remove_piece(piece_data: PieceSpawnData):
    pieces_on_board[piece_data.position.x][piece_data.position.y] = null
    captured_pieces.append(piece_data)


func get_piece_at(pos: Vector2i) -> PieceSpawnData:
    return pieces_on_board[pos.x][pos.y]


func is_valid_position(pos: Vector2i) -> bool:
    return pos.x >= 0 and pos.x < config.grid_size.x and pos.y >= 0 and pos.y < config.grid_size.y


func is_position_occupied(pos: Vector2i) -> bool:
    return get_piece_at(pos) != null


func is_position_occupied_by_opponent(pos: Vector2i, piece: PieceSpawnData) -> bool:
    var other_piece = get_piece_at(pos)
    # true if there is a piece and it doesn't match this piece's color
    return other_piece and piece.color != other_piece.color


func get_legal_moves_for_piece(_piece_data: PieceSpawnData) -> Array[Vector2i]:
    return []

