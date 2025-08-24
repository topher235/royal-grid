@tool
class_name ChessBoard extends Node2D

signal piece_moved(from_pos: Vector2i, to_pos: Vector2i)
signal piece_captured(pos: Vector2i)
signal turn_over(did_capture: bool)

const TILE_SCENE = preload("res://scenes/board/tile.tscn")
const PIECE_SCENE = preload("res://scenes/pieces/chess_piece.tscn")

@export var piece_spawner: PieceSpawner
@export var game_config: GameConfig

var game_state: GameState
var tiles: Array[Array] = []
var pieces: Array[Array] = []
var selected_tile: Tile = null


func _ready() -> void:
    if not game_config:
        game_config = GameConfig.default_game()
    piece_spawner.game_config = game_config
    
    initialize_grid()
    create_tiles()
    load_new_game()


func initialize_grid() -> void:
    tiles.resize(game_config.grid_size.x)
    pieces.resize(game_config.grid_size.x)

    for x in range(game_config.grid_size.x):
        tiles[x] = []
        pieces[x] = []
        tiles[x].resize(game_config.grid_size.y)
        pieces[x].resize(game_config.grid_size.y)

        for y in range(game_config.grid_size.y):
            tiles[x][y] = null
            pieces[x][y] = null


func create_tiles() -> void:
    for x in range(game_config.grid_size.x):
        for y in range(game_config.grid_size.y):
            var tile = TILE_SCENE.instantiate() as Tile
            tile.grid_position = Vector2i(x, y)
            tile.set_size(Vector2(game_config.tile_size, game_config.tile_size))
            tile.position = Vector2(x * game_config.tile_size, y * game_config.tile_size)
            tile.tile_clicked.connect(_on_tile_clicked)
            tiles[x][y] = tile
            add_child(tile)


func load_new_game() -> void:
    clear_board()

    # game_state = GameState.new()
    # game_state.config = game_config
    # game_state.pieces_on_board = game_config.starting_pieces.duplicate()

    for piece_data in game_config.starting_pieces:
        spawn_piece(piece_data)


func spawn_piece(piece_data: PieceSpawnData) -> void:
    print("spawning at ", piece_data.position)
    var piece = PIECE_SCENE.instantiate()
    if piece:
        piece.data = piece_data
        place_piece(piece, piece_data.position)


func clear_board() -> void:
    for x in range(game_config.grid_size.x):
        for y in range(game_config.grid_size.y):
            if tiles[x][y].is_occupied:
                remove_piece(Vector2i(x, y))


func _on_tile_clicked(tile: Tile) -> void:
    if selected_tile == null:
        # First click - select tile if it has a piece
        if tile.is_occupied:
            select_tile(tile)
            show_valid_moves(tile)
    else:
        # Second click - attempt move
        if tile != selected_tile:
            var move_successful = attempt_move(selected_tile, tile)
            if move_successful:
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

    for move_pos in valid_moves:
        if is_valid_position(move_pos):
            tiles[move_pos.x][move_pos.y].show_valid_move()


func attempt_move(from_tile: Tile, to_tile: Tile) -> bool:
    var from_pos = from_tile.grid_position
    var to_pos = to_tile.grid_position

    if not from_tile.is_occupied or not from_tile.occupying_piece:
        print("No piece to move")
        return false
    
    var piece = from_tile.occupying_piece
    if not piece:
        print("Invalid piece type")
        return false
    
    if not can_piece_move_to(piece, to_pos):
        print("Illegal move for piece")
        return false

    if move_piece(from_pos, to_pos):
        # Update piece's internal position
        piece.set_grid_position(to_pos)
        # piece.move_to(to_pos)
        return true
    else:
        print("move failed")
        return false


func is_valid_position(pos: Vector2i) -> bool:
    var is_within_x = pos.x >= 0 and pos.x < game_config.grid_size.x
    var is_within_y = pos.y >= 0 and pos.y < game_config.grid_size.y
    return is_within_x and is_within_y


func is_position_occupied(pos: Vector2i) -> bool:
    if not is_valid_position(pos):
        return false
    return tiles[pos.x][pos.y].is_occupied


func is_position_occupied_by_opponent(pos: Vector2i, piece: PieceSpawnData) -> bool:
    var other_piece = get_piece_at(pos)
    # true if there is a piece and it doesn't match this piece's color
    return other_piece and piece.color != other_piece.color


func place_piece(piece: ChessPiece, pos: Vector2i) -> bool:
    if not is_valid_position(pos) or is_position_occupied(pos):
        return false
    
    pieces[pos.x][pos.y] = piece
    var tile = tiles[pos.x][pos.y]
    tile.set_occupancy(piece)
    return true


func remove_piece(pos: Vector2i) -> ChessPiece:
    if not is_valid_position(pos) or not is_position_occupied(pos):
        return null
    
    var piece = pieces[pos.x][pos.y]
    pieces[pos.x][pos.y] = null
    var tile = tiles[pos.x][pos.y]
    tile.remove_piece(piece)
    return piece


func move_piece(from_pos: Vector2i, to_pos: Vector2i) -> bool:
    if not is_valid_position(from_pos) or not is_valid_position(to_pos):
        return false
    
    if not is_position_occupied(from_pos):
        return false
    
    var piece = pieces[from_pos.x][from_pos.y]
    if not piece:
        return false
    
    var did_capture = false
    if is_position_occupied(to_pos):
        did_capture = true
        var captured_piece = remove_piece(to_pos)
        piece_captured.emit(to_pos)
        captured_piece.queue_free()
    
    remove_piece(from_pos)
    place_piece(piece, to_pos)
    piece_moved.emit(from_pos, to_pos)
    turn_over.emit(did_capture)
    return true


func get_world_to_grid(world_pos: Vector2) -> Vector2i:
    return Vector2i(int(world_pos.x / game_config.tile_size), int(world_pos.y / game_config.tile_size))


func get_piece_at(pos: Vector2i) -> ChessPiece:
    if not is_valid_position(pos):
        return null
    return tiles[pos.x][pos.y].occupying_piece as ChessPiece


func can_piece_move_to(piece: ChessPiece, target_pos: Vector2i) -> bool:
    if not piece or not is_valid_position(target_pos):
        return false
    
    var legal_moves = piece.get_legal_moves()
    return target_pos in legal_moves
