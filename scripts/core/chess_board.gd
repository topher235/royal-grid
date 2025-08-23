@tool
extends Node2D

signal piece_moved(from_pos: Vector2i, to_pos: Vector2i)
signal piece_captured(pos: Vector2i)

const GRID_SIZE := 5
const TILE_SIZE := 32
const TILE_SCENE = preload("res://scenes/board/tile.tscn")

var tiles: Array[Array] = []
var pieces: Array[Array] = []
var selected_tile: Tile = null


func _ready() -> void:
    initialize_grid()
    create_tiles()


func initialize_grid() -> void:
    tiles.resize(GRID_SIZE)
    pieces.resize(GRID_SIZE)

    for x in range(GRID_SIZE):
        tiles[x] = []
        pieces[x] = []
        tiles[x].resize(GRID_SIZE)
        pieces[x].resize(GRID_SIZE)

        for y in range(GRID_SIZE):
            tiles[x][y] = null
            pieces[x][y] = null


func create_tiles() -> void:
    for x in range(GRID_SIZE):
        for y in range(GRID_SIZE):
            var tile = TILE_SCENE.instantiate() as Tile
            tile.grid_position = Vector2i(x, y)
            tile.position = Vector2(x * TILE_SIZE, y * TILE_SIZE)
            tile.tile_clicked.connect(_on_tile_clicked)
            tiles[x][y] = tile
            add_child(tile)


func _on_tile_clicked(tile: Tile) -> void:
    if selected_tile == null:
        # First click - select tile if it has a piece
        if tile.is_occupied:
            select_tile(tile)
            show_valid_moves(tile)
    else:
        # Second click - attempt move
        if tile != selected_tile:
            attempt_move(selected_tile, tile)
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
    var valid_moves = piece.get_legal_moves()

    for move_pos in valid_moves:
        if is_valid_position(move_pos):
            tiles[move_pos.x][move_pos.y].show_valid_move()


func attempt_move(from_tile: Tile, to_tile: Tile) -> void:
    var from_pos = from_tile.grid_position
    var to_pos = to_tile.grid_position

    if move_piece(from_pos, to_pos):
        print("Move successful")
        if to_tile.is_occupied:
            print("piece captured!")
    else:
        print("invalid move")


func is_valid_position(pos: Vector2i) -> bool:
    return pos.x >= 0 and pos.x < GRID_SIZE and pos.y >= 0 and pos.y < GRID_SIZE


func is_tile_occupied(pos: Vector2i) -> bool:
    if not is_valid_position(pos):
        return false
    return tiles[pos.x][pos.y].is_occupied


func place_piece(piece: Node2D, pos: Vector2i) -> bool:
    if not is_valid_position(pos) or is_tile_occupied(pos):
        return false
    
    pieces[pos.x][pos.y] = piece
    tiles[pos.x][pos.y].set_occupancy(piece)
    piece.position = Vector2(pos.x * TILE_SIZE + TILE_SIZE/2, pos.y * TILE_SIZE + TILE_SIZE/2)
    add_child(piece)
    return true


func remove_piece(pos: Vector2i) -> Node2D:
    if not is_valid_position(pos) or not is_tile_occupied(pos):
        return null
    
    var piece = pieces[pos.x][pos.y]
    pieces[pos.x][pos.y] = null
    tiles[pos.x][pos.y].set_occupancy(null)
    piece.get_parent().remove_child(piece)
    return piece


func move_piece(from_pos: Vector2i, to_pos: Vector2i) -> bool:
    if not is_valid_position(from_pos) or not is_valid_position(to_pos):
        return false
    
    if not is_tile_occupied(from_pos):
        return false
    
    var piece = pieces[from_pos.x][from_pos.y]
    if not piece:
        return false
    
    if is_tile_occupied(to_pos):
        var captured_piece = remove_piece(to_pos)
        piece_captured.emit(to_pos)
        captured_piece.queue_free()
    
    remove_piece(from_pos)
    place_piece(piece, to_pos)
    piece_moved.emit(from_pos, to_pos)
    return true


func get_world_to_grid(world_pos: Vector2) -> Vector2i:
    return Vector2i(int(world_pos.x / TILE_SIZE), int(world_pos.y / TILE_SIZE))
