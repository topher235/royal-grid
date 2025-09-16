class_name Map extends Resource

@export var map_id := 0
@export var map_name := "Default Map"
@export var preview: Texture2D
@export var background_sprite: Texture2D
@export var tile_data: Array[Array] = []  # 2D array of MapTiles
@export var grid_size: Vector2i = Vector2i(4, 4)
@export var priority := 0  # Used to order in config selection, higher priority will be closer to front of list


func _init(id: int = 0, name: String = "Classic", size: Vector2i = Vector2i(4, 4)) -> void:
    map_id = id
    map_name = name
    grid_size = size
    initialize_tile_data()


func initialize_tile_data() -> void:
    """
    Initialize the 2D array of tile data based on the grid size.
    """
    tile_data.clear()
    tile_data.resize(grid_size.x)

    for x in range(grid_size.x):
        tile_data[x] = []
        tile_data[x].resize(grid_size.y)

        for y in range(grid_size.y):
            tile_data[x][y] = MapTile.new(Vector2i(x, y), true)


func resize_grid(new_size: Vector2i) -> void:
    """
    Resize the grid and reinitialize tile data.
    """
    grid_size = new_size
    initialize_tile_data()


func get_tile_data(pos: Vector2i) -> MapTile:
    """
    Get the tile data at the specified location.
    """
    if not is_valid_position(pos):
        return null
    return tile_data[pos.x][pos.y]


func is_valid_position(pos: Vector2i) -> bool:
    """
    Check if the position is within the grid bounds.
    """
    return pos.x >= 0 and pos.x < grid_size.x and pos.y >= 0 and pos.y < grid_size.y


func is_tile_active(pos: Vector2i) -> bool:
    """
    Check if the tile at the given position is active (playable).
    """
    var tile = get_tile_data(pos)
    return tile != null and tile.is_active


func set_tile_active(pos: Vector2i, active: bool) -> void:
    """
    Set whether a tile is active or not.
    """
    var tile = get_tile_data(pos)
    if tile:
        tile.is_active = active


func get_active_tiles() -> Array[Vector2i]:
    """
    Get all positions of active tiles.
    """
    var active_tiles: Array[Vector2i] = []
    for x in range(grid_size.x):
        for y in range(grid_size.y):
            var pos = Vector2i(x, y)
            if is_tile_active(pos):
                active_tiles.append(pos)
    return active_tiles


func toggle_tile(pos: Vector2i) -> void:
    """
    Toggle the active state of a tile.
    """
    var tile = get_tile_data(pos)
    if tile:
        tile.is_active = not tile.is_active


static func create_default_map() -> Map:
    """
    Create the default 4x4 map with all tiles active.
    """
    var map = Map.new(0, "Classic", Vector2i(4, 4))
    return map


static func create_custom_map(id: int, name: String, size: Vector2i, disabled_positions: Array[Vector2i]) -> Map:
    """
    Create a custom map with the specified disabled positions.
    """
    var map = Map.new(id, name, size)

    # Disable specified positions
    for pos in disabled_positions:
        map.set_tile_active(pos, false)
    
    return map
