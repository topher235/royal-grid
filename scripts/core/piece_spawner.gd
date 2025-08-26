class_name PieceSpawner extends Node

@export var chess_board: ChessBoard
@export var game_config: GameConfig

var rng: RandomNumberGenerator


func _ready() -> void:
    rng = RandomNumberGenerator.new()
    rng.randomize()


func should_spawn_piece(did_capture: bool, override: bool) -> bool:
    if not game_config or not game_config.piece_spawn_rules:
        print("Missing game config or spawn rules")
        return false
    
    var rules = game_config.piece_spawn_rules

    if not rules.spawn_pieces_on_empty_turn:
        print("Do not spawn pieces on empty turn")
        return false
    
    var current_piece_count = get_current_piece_count()
    if current_piece_count >= rules.max_pieces_on_board:
        print("Do not spawn more than max number of pieces")
        return false
    
    if override:
        return true
    
    # If player captured a piece then there's a chance a new one does not spawn
    if did_capture:
        var chance = rng.randf()
        print("Rolled ", chance, " out of ", rules.piece_spawn_chance)
        return chance < rules.piece_spawn_chance
    
    return true


func spawn_random_piece(did_capture: bool, override: bool = false) -> void:
    if not should_spawn_piece(did_capture, override):
        return
    
    var empty_position = find_random_empty_position()
    if empty_position == Vector2i(-1, -1):
        return
    
    var piece_data = create_random_piece_data(empty_position)
    if not piece_data:
        return
    
    chess_board.spawn_piece(piece_data)


func spawn_from_data(piece_data: PieceSpawnData) -> void:
    var empty_position = find_random_empty_position()
    if empty_position == Vector2i(-1, -1):
        return
    
    piece_data.position = empty_position
    chess_board.spawn_piece(piece_data)


func find_random_empty_position() -> Vector2i:
    if not chess_board or not game_config:
        return Vector2i(-1, -1)
    
    var empty_positions: Array[Vector2i] = []

    for x in range(game_config.grid_size.x):
        for y in range(game_config.grid_size.y):
            var pos = Vector2i(x, y)
            if not chess_board.is_position_occupied(pos):
                empty_positions.append(pos)
    
    if empty_positions.is_empty():
        return Vector2i(-1, -1)
    
    return empty_positions[rng.randi() % empty_positions.size()]


func create_random_piece_data(position: Vector2i) -> PieceSpawnData:
    if not game_config or not game_config.piece_spawn_rules:
        return null
    

    var rules = game_config.piece_spawn_rules
    var piece_data = PieceSpawnData.new()

    piece_data.position = position

    # NOTE: this could be weighted to make it harder or easier for the player
    #   if the board is full of white, then adding another white piece will make it harder
    #   for the player to play
    piece_data.color = rng.randi() % 2 == 0

    var piece_type = select_random_piece_type(rules.piece_type_weights)
    piece_data.piece_type = piece_type

    piece_data._init_rules()
    return piece_data


func select_random_piece_type(weights: Dictionary) -> int:
    if weights.is_empty():
        return PieceSpawnData.PieceType.PAWN
    
    var total_weight = 0.0
    for weight in weights.values():
        total_weight += weight
    
    if total_weight <= 0:
        return PieceSpawnData.PieceType.PAWN
    
    var random_value = rng.randf() * total_weight

    var current_weight = 0.0
    for piece_name in weights.keys():
        current_weight += weights[piece_name]
        if random_value <= current_weight:
            match piece_name:
                "pawn":
                    return PieceSpawnData.PieceType.PAWN
                "rook":
                    return PieceSpawnData.PieceType.ROOK
                "knight":
                    return PieceSpawnData.PieceType.KNIGHT
                "bishop":
                    return PieceSpawnData.PieceType.BISHOP
                "queen":
                    return PieceSpawnData.PieceType.QUEEN
                "king":
                    return PieceSpawnData.PieceType.KING
    
    # Fallback to pawn
    return PieceSpawnData.PieceType.PAWN


func get_current_piece_count() -> int:
    if not chess_board or not game_config:
        return 0
    
    var count = 0
    for x in range(game_config.grid_size.x):
        for y in range(game_config.grid_size.y):
            if chess_board.is_position_occupied(Vector2i(x, y)):
                count += 1
    
    return count


func spawn_piece_at_position(position: Vector2i, piece_type: int, color: bool) -> void:
    if not chess_board or not game_config:
        return
    
    # Check if position is valid and empty
    if not chess_board.is_valid_position(position) or chess_board.is_position_occupied(position):
        return
    
    # Create piece data
    var piece_data = PieceSpawnData.new()
    piece_data.position = position
    piece_data.piece_type = piece_type
    piece_data.color = color
    piece_data._init_rules()
    
    # Spawn the piece
    chess_board.spawn_piece(piece_data)
