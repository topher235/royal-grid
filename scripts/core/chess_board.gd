@tool
class_name ChessBoard extends Node2D

signal new_game
signal piece_moved(piece: ChessPiece, from_pos: Vector2i, to_pos: Vector2i)
signal piece_captured(piece_used: ChessPiece, piece_captured: ChessPiece)
signal turn_over(did_capture: bool)
signal game_over(final_score: int)

const TILE_SCENE = preload("res://scenes/board/tile.tscn")
const PIECE_SCENE = preload("res://scenes/pieces/chess_piece.tscn")
const EFFECT_SCENE = preload("res://scenes/board/effect.tscn")

@export var piece_spawner: PieceSpawner
@export var game_config: GameConfig:
    set = _set_game_config
@export var game_manager: GameManager
@export var effect_spawner: EffectSpawner
@export var animator: ChessBoardAnimator

var game_state: GameState
var tiles: Array[Array] = []
var pieces: Array[Array] = []
var selected_tile: Tile = null


func _ready() -> void:
    if game_config:
        piece_spawner.game_config = game_config
        effect_spawner.game_config = game_config
    piece_spawner.game_over.connect(_on_piece_spawner_game_over)
    
func _set_game_config(value: GameConfig) -> void:
    game_config = value
    
    if piece_spawner:
        piece_spawner.game_config = game_config
        
    if effect_spawner:
        effect_spawner.game_config = game_config
    

func initialize_grid() -> void:
    var grid_size = game_config.grid_size
    tiles.resize(grid_size.x)
    pieces.resize(grid_size.x)

    for x in range(grid_size.x):
        tiles[x] = []
        pieces[x] = []
        tiles[x].resize(grid_size.y)
        pieces[x].resize(grid_size.y)

        for y in range(grid_size.y):
            tiles[x][y] = null
            pieces[x][y] = null


func create_tiles() -> void:
    var grid_size := game_config.grid_size
    for x in range(grid_size.x):
        for y in range(grid_size.y):
            var tile_data := game_config.map.get_tile_data(Vector2i(x, y))
            # Only create tiles for active positions
            if tile_data and tile_data.is_active:
                var tile := TILE_SCENE.instantiate() as Tile
                tile.grid_position = Vector2i(x, y)
                tile.custom_minimum_size = Vector2(game_config.tile_size, game_config.tile_size + (game_config.tile_size * 0.25))
                tile.position = Vector2(x * game_config.tile_size, y * game_config.tile_size)
                tile.tile_clicked.connect(_on_tile_clicked)
                tiles[x][y] = tile
                add_child(tile)
            else:
                # Set inactive tiles to null
                tiles[x][y] = null


func load_new_game() -> void:
    initialize_grid()
    create_tiles()
    clear_board()

    if not game_config:
        return
    
    new_game.emit()

    for piece_data in game_config.starting_pieces:
        spawn_piece(piece_data)
        await get_tree().create_timer(0.2).timeout
    for i in range(game_config.num_random_pieces):
        game_manager.spawn_new_piece()
        await get_tree().create_timer(0.2).timeout


func spawn_piece(piece_data: PieceSpawnData) -> void:
    var piece = PIECE_SCENE.instantiate()
    if piece:
        piece.data = piece_data
        var success = place_piece(piece, piece_data.position)
        if success:
            # if the tile had an effect, remove it so that we don't double up on things on the tile
            var tile = tiles[piece_data.position.x][piece_data.position.y]
            if tile.is_occupied_by_effect():
                var effect = tile.remove_effect()
                effect.queue_free()
        piece.animate_spawn()
    else:
        Log.error(self, "failed to instantiate new piece scene")


func spawn_effect(effect_data: EffectSpawnData) -> void:
    var effect = EFFECT_SCENE.instantiate()
    if effect:
        effect.data = effect_data
        add_effect(effect, effect_data.position)


func clear_board() -> void:
    var grid_size = game_config.grid_size
    for x in range(grid_size.x):
        for y in range(grid_size.y):
            var tile = tiles[x][y]
            if tile and tile.is_occupied:
                remove_piece(Vector2i(x, y))
            if tile and tile.is_occupied_by_effect():
                tile.remove_effect()


func _on_tile_clicked(tile: Tile) -> void:
    if selected_tile == null:
        if tile.is_frozen():
            tile.animate_frozen()
        # First click - select tile if it has a piece
        elif tile.occupying_piece:
            select_tile(tile)
            show_valid_moves(tile)
    else:
        # Second click - attempt move
        if tile != selected_tile:
            attempt_move(selected_tile, tile)
            deselect_current_tile()
        else:
            # Deselect current tile
            deselect_current_tile()


func select_tile(tile: Tile) -> void:
    if selected_tile:
        selected_tile.deselect()
    selected_tile = tile
    tile.select()


func deselect_current_tile() -> void:
    if selected_tile:
        selected_tile.deselect()
        selected_tile = null
        clear_all_indicators()


func clear_all_indicators() -> void:
    get_tree().call_group("tiles", "clear_indicators")


func show_valid_moves(tile: Tile) -> void:
    if not tile.is_occupied or not tile.occupying_piece:
        return
    
    var piece = tile.occupying_piece
    if not piece:
        return
    
    var valid_moves = piece.get_legal_moves()

    var blocked_spaces = []
    for effect in get_tree().get_nodes_in_group("effects"):
        if not effect.can_piece_move_to():
            blocked_spaces.append(effect.grid_position)

    for move_pos in valid_moves:
        if is_valid_position(move_pos) and not move_pos in blocked_spaces:
            var target_tile = tiles[move_pos.x][move_pos.y]
            if target_tile:  # Only show valid moves on active tiles
                target_tile.show_valid_move()


func attempt_move(from_tile: Tile, to_tile: Tile) -> bool:
    var from_pos = from_tile.grid_position
    var to_pos = to_tile.grid_position

    if not from_tile.is_occupied_by_piece():
        Log.error(self, "No piece to move")
        return false
    
    var piece = from_tile.occupying_piece
    if not piece:
        Log.error(self, "Invalid piece type")
        return false
    
    if not can_piece_move_to(piece, to_pos):
        Log.error(self, "Illegal move for piece")
        piece.animate_error()
        return false

    if await move_piece(from_pos, to_pos):
        # Update piece's internal position
        piece.set_grid_position(to_pos)
        return true
    else:
        Log.error(self, "attempt_move: move failed")
        return false


func is_valid_position(pos: Vector2i) -> bool:
    var grid_size = game_config.grid_size
    var is_within_x = pos.x >= 0 and pos.x < grid_size.x
    var is_within_y = pos.y >= 0 and pos.y < grid_size.y
    return is_within_x and is_within_y and game_config.map.is_tile_active(pos)


func is_position_occupied(pos: Vector2i) -> bool:
    if not is_valid_position(pos):
        return false
    var tile = tiles[pos.x][pos.y]
    return tile and tile.is_occupied


func is_position_occupied_by_opponent(pos: Vector2i, piece: PieceSpawnData) -> bool:
    var other_piece = get_piece_at(pos)
    # true if there is a piece and it doesn't match this piece's color
    return other_piece and piece.color != other_piece.color


func is_position_occupied_by_effect(pos: Vector2i) -> bool:
    var tile = tiles[pos.x][pos.y]
    return tile and tile.is_occupied_by_effect()


func place_piece(piece: ChessPiece, pos: Vector2i) -> bool:
    if not is_valid_position(pos):
        Log.error(self, str(pos) + " is not a valid position")
        return false
    
    var tile = tiles[pos.x][pos.y]
    if not tile or tile.is_occupied_by_piece():
        Log.error(self, str(pos) + " is occupied by a piece")
        return false
    
    # Remove from parent so it can be reparented to the tile
    var piece_parent = piece.get_parent()
    if piece_parent:
        piece_parent.remove_child(piece)
    else:
        Log.info(self, "piece has no parent")

    pieces[pos.x][pos.y] = piece
    tile.set_occupancy(piece)
    return true


func remove_piece(pos: Vector2i) -> ChessPiece:
    if not is_valid_position(pos) or not is_position_occupied(pos):
        return null
    
    var piece = pieces[pos.x][pos.y]
    pieces[pos.x][pos.y] = null
    var tile = tiles[pos.x][pos.y]
    tile.remove_piece(piece)

    # temporarily reparent to the board
    add_child(piece)
    piece.position = tile.position

    return piece


func remove_effect(pos: Vector2i) -> Effect:
    if not is_valid_position(pos):
        return null
    
    var tile = tiles[pos.x][pos.y]
    if not tile:
        return null
    
    var effect = tile.remove_effect()
    return effect


func move_piece(from_pos: Vector2i, to_pos: Vector2i) -> bool:
    if not is_valid_position(from_pos) or not is_valid_position(to_pos):
        return false
    
    if not is_position_occupied(from_pos):
        return false
    
    var piece = pieces[from_pos.x][from_pos.y]
    if not piece:
        return false
    
    remove_piece(from_pos)
    var did_capture = false
    if is_position_occupied_by_opponent(to_pos, piece.data):
        did_capture = true
        var captured_piece = remove_piece(to_pos)
        captured_piece.animate_capture()
        piece_captured.emit(piece, captured_piece)
    if is_position_occupied_by_effect(to_pos):
        var captured_effect = remove_effect(to_pos)
        if captured_effect:
            captured_effect.execute()

    await animator.animate_piece_move(piece, from_pos, to_pos)
    place_piece(piece, to_pos)
    piece_moved.emit(piece, from_pos, to_pos)
    turn_over.emit(did_capture)
    return true


func add_effect(effect: Effect, pos: Vector2i) -> bool:
    if not is_valid_position(pos) or is_position_occupied(pos):
        return false
    
    var tile = tiles[pos.x][pos.y]
    if not tile:
        return false
    
    tile.add_effect(effect)
    return true


func get_world_to_grid(world_pos: Vector2) -> Vector2i:
    return Vector2i(int(world_pos.x / game_config.tile_size), int(world_pos.y / game_config.tile_size))


func get_piece_at(pos: Vector2i) -> ChessPiece:
    if not is_valid_position(pos):
        return null
    var tile = tiles[pos.x][pos.y]
    return tile.occupying_piece as ChessPiece if tile else null


func can_piece_move_to(piece: ChessPiece, target_pos: Vector2i) -> bool:
    if not piece or not is_valid_position(target_pos):
        return false
    
    var legal_moves = piece.get_legal_moves()
    return target_pos in legal_moves


func does_position_have_piece(pos: Vector2i) -> bool:
    if not is_valid_position(pos):
        return false
    
    return pieces[pos.x][pos.y] != null


func retrieve_tile_at_position(pos: Vector2i) -> Tile:
    if not is_valid_position(pos):
        return null
    return tiles[pos.x][pos.y]


func get_game_state() -> ActiveGameData:
    """
    Creates an ActiveGameData object from the current board state.
    """
    var active_game = ActiveGameData.new()

    # Get current score from game manager
    if game_manager:
        active_game.score = game_manager.score
        active_game.stats = game_manager.current_game_stats
    
    # Set default map and character IDs (TODO: implement later)
    active_game.map_id = game_config.map.map_id
    active_game.character_id = 0

    # Serialize tiles (while tiles are available)
    active_game.tiles = [] as Array[ActiveTileData]
    for x in range(game_config.grid_size.x):
        for y in range(game_config.grid_size.y):
            var tile = tiles[x][y]
            if tile:
                # Only serialize active tiles
                active_game.tiles.append(tile.get_active_tile_data())
    
    # Serialize pieces on the board
    active_game.pieces = [] as Array[ActivePieceData]
    for x in range(game_config.grid_size.x):
        for y in range(game_config.grid_size.y):
            var piece = pieces[x][y]
            if piece:
                active_game.pieces.append(piece.get_active_piece_data())
    
    # Serialize next piece - it's not a ChessPiece scene, so can't do like the above serialization
    var next_piece: PieceSpawnData = game_manager.retrieve_next_piece()
    var piece_data = ActivePieceData.new()
    piece_data.piece_type = next_piece.piece_type
    piece_data.color = next_piece.color
    active_game.next_piece = piece_data

    # Serialize effects on the board
    active_game.effects = [] as Array[ActiveEffectData]
    for effect in get_tree().get_nodes_in_group("effects"):
        if effect.has_method("get_active_effect_data"):
            active_game.effects.append(effect.get_active_effect_data())
    
    return active_game


func load_game_state(active_game: ActiveGameData) -> void:
    """
    Loads a game state from ActiveGameData.
    """
    if not active_game:
        Log.error(self, "Cannot load null game state")
        return
    
    # TODO: load the correct map based on map_id
    initialize_grid()
    create_tiles()

    # Set score in game manager
    if game_manager:
        game_manager.score = active_game.score
        Events.score_updated.emit(active_game.score)
        game_manager.score_multiplier = active_game.mult
        game_manager.score_multiplier_duration = active_game.mult_duration
        game_manager.current_game_stats = active_game.stats
        # Load next piece
        var piece_data = active_game.next_piece
        var spawn_data = PieceSpawnData.new()
        spawn_data.piece_type = piece_data.piece_type
        spawn_data.color = piece_data.color
        game_manager.set_next_piece(spawn_data)
    
    # Load tiles
    for tile_data in active_game.tiles:
        var tile = tiles[tile_data.position.x][tile_data.position.y]
        if tile:
            tile.load_from_active_data(tile_data)
    
    # Load pieces
    for piece_data in active_game.pieces:
        var spawn_data = PieceSpawnData.new()
        spawn_data.piece_type = piece_data.piece_type
        spawn_data.position = piece_data.position
        spawn_data.color = piece_data.color
        spawn_piece(spawn_data)
    
    # Load effects
    for effect_data in active_game.effects:
        if not effect_data.effect_id in SpecialEffectDatabase.DB.keys():
            Log.error(self, "Did not find " + str(effect_data.effect_id) + " id in effect database.")
            continue
        var special_effect_cls = SpecialEffectDatabase.DB[effect_data.effect_id]
        var special_effect = special_effect_cls.new()
        special_effect.duration = effect_data.remaining_duration
        var spawn_data = EffectSpawnData.new(effect_data.position, special_effect)
        spawn_effect(spawn_data)
    
    Log.info(self, "Game state loaded successfully")

    
func _on_piece_spawner_game_over() -> void:
    get_tree().set_pause(true)
    game_manager.end_game()
