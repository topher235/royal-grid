class_name PieceSpawner extends Node

signal game_over

@export var chess_board: ChessBoard
@export var game_config: GameConfig

var rng: RandomNumberGenerator
var next_piece_data: PieceSpawnData
var timer: Timer


func _ready() -> void:
    rng = RandomNumberGenerator.new()
    rng.randomize()
    chess_board.new_game.connect(_on_new_game)


func _on_new_game() -> void:
    get_tree().create_timer(0.5).timeout.connect(_debounced_new_game_setup)
    
    
func _debounced_new_game_setup() -> void:
    """
    Sets up this node for a new game. If the spawn rules state that pieces spawn on a timer, aka RUSH mode,
    then we dynamically create a timer here and add it as a child. Otherwise, the GameManager
    will tell this node when the turn is over and the piece will spawn then.
    
    The other steps are to create the first upcoming piece and connect signals.
    """
    if game_config and game_config.piece_spawn_rules.spawn_on_timer:
        timer = Timer.new()
        timer.wait_time = game_config.piece_spawn_rules.spawn_frequency
        timer.one_shot = false  # keep going forever
        timer.autostart = true
        timer.timeout.connect(spawn_next_piece.bind(false))
        add_child(timer)
    next_piece_data = create_random_piece_data(find_random_empty_position([]))
    Events.next_piece_generated.emit(next_piece_data)


func should_spawn_piece(did_capture: bool, override: bool) -> bool:
    if not game_config or not game_config.piece_spawn_rules:
        Log.info(self, "Missing game config or spawn rules")
        return false
    
    var rules = game_config.piece_spawn_rules

    if not rules.spawn_pieces_on_empty_turn:
        Log.info(self, "Do not spawn pieces on empty turn")
        return false
    
    var current_piece_count = get_current_piece_count()
    if current_piece_count >= rules.max_pieces_on_board:
        Log.info(self, "Do not spawn more than max number of pieces")
        game_over.emit()
        return false
    
    if override:
        return true
    
    # If player captured a piece then there's a chance a new one does not spawn
    if did_capture:
        var chance = rng.randf()
        Log.info(self, "Rolled " + str(chance) + " out of " + str(rules.piece_spawn_chance))
        return chance < rules.piece_spawn_chance
    
    return true


func spawn_next_piece(did_capture: bool, override: bool = false) -> void:
    """
    Tries to spawn the piece that is currently being previewed, aka. the next piece.
    """
    if not should_spawn_piece(did_capture, override):
        Log.info(self, "spawn_next_piece should not spawn piece")
        return
    
    var empty_position = find_random_empty_position([])
    if empty_position == Vector2i(-1, -1):
        Log.error(self, "spawn_next_piece got an empty position of (-1, -1)")
        game_over.emit()
        return
    
    var piece_data = next_piece_data
    if not piece_data:
        Log.error(self, "spawn_next_piece Expected piece data not available")
        return
    
    # We created this data last move, so the position could now be occupied
    # right before placing, we set the position to the newly calculated empty position
    # note: this function does create the next piece with this same position,
    #   but when we get to the next spawn, we'll be re-calculating the empty position
    piece_data.position = empty_position
    
    Events.next_piece_is_spawning.emit()
    chess_board.spawn_piece(piece_data)
    next_piece_data = create_random_piece_data(empty_position)
    Events.next_piece_generated.emit(next_piece_data)


func spawn_new_piece() -> void:
    """
    Spawns a random piece on an empty position.
    """
    var empty_position = find_random_empty_position([])
    if empty_position == Vector2i(-1, -1):
        Log.info(self, "spawn_new_piece: Got an empty position of (-1, -1)")
        game_over.emit()
        return
    
    var piece_data = create_random_piece_data(empty_position)
    if not piece_data:
        Log.error(self, "spawn_new_piece: Piece data is null")
        return
    
    chess_board.spawn_piece(piece_data)


func spawn_from_data(piece_data: PieceSpawnData, excluding_positions: Array = []) -> void:
    var empty_position = find_random_empty_position(excluding_positions)
    if empty_position == Vector2i(-1, -1):
        Log.info(self, "spawn_from_data found empty position (-1, -1)")
        return
    
    piece_data.position = empty_position
    chess_board.spawn_piece(piece_data)


func find_random_empty_position(excluding_positions: Array) -> Vector2i:
    if not chess_board or not game_config:
        return Vector2i(-1, -1)
    
    var empty_positions: Array[Vector2i] = []

    var active_tile_positions: Array[Vector2i] = game_config.get_active_tile_positions()
    for pos in active_tile_positions:
        if pos in excluding_positions:
            continue
        if not chess_board.is_position_occupied(pos):
            empty_positions.append(pos)
    
    if empty_positions.is_empty():
        return Vector2i(-1, -1)
    
    return empty_positions[rng.randi() % empty_positions.size()]


func create_random_piece_data(position: Vector2i) -> PieceSpawnData:
    if not game_config or not game_config.piece_spawn_rules:
        Log.error(self, "missing game config")
        return null
        
    var rules = game_config.piece_spawn_rules
    var piece_data = PieceSpawnData.new()

    piece_data.position = position

    # NOTE: this could be weighted to make it harder or easier for the player
    #   if the board is full of white, then adding another white piece will make it harder
    #   for the player to play
    piece_data.color = rng.randi() % 2 == 0

    var piece_type_weights := game_config.get_piece_type_weights()
    var piece_type := select_random_piece_type(piece_type_weights)
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


func retrieve_next_piece() -> PieceSpawnData:
    return next_piece_data


func set_next_piece(spawn_data: PieceSpawnData) -> void:
    next_piece_data = spawn_data
    Events.next_piece_generated.emit(next_piece_data)

    
func end_turn(did_capture: bool) -> void:
    """
    An entry point for the GameManager to interact with this at turn's end, so that
    we can keep the `spawn_next_piece` function more general to the actual logic for
    spawning the next piece.
    
    Using this `end_turn` nomenclature allows us to early exit if the rules say we
    should be spawning on a timer instead.
    """
    if game_config.piece_spawn_rules.spawn_on_timer:
        return

    # not on a timer, spawn every turn
    spawn_next_piece(did_capture)
    