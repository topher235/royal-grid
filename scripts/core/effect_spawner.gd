class_name EffectSpawner extends Node

@export var chess_board: ChessBoard
@export var game_config: GameConfig

var rng: RandomNumberGenerator


func _ready() -> void:
    rng = RandomNumberGenerator.new()
    rng.randomize()


func should_spawn_effect(num_moves: int, override: bool = false) -> bool:
    if not game_config:  # or not game_config.effect_spawn_rules:
        return false
    
    # var rules = game_config.effect_spawn_rules

    if override:
        return true
    
    # TODO: refactor to use rules system if this gets more complex
    return true
    # return num_moves % 3 == 0


func spawn_random_effect(num_moves: int, override: bool = false) -> void:
    if not should_spawn_effect(num_moves, override):
        return
    
    var empty_position = find_random_empty_position()
    if empty_position == Vector2i(-1, -1):
        return
    
    var effect_data: EffectSpawnData = create_random_effect_data(empty_position)
    if not effect_data:
        return
    
    chess_board.spawn_effect(effect_data)


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


func create_random_effect_data(position: Vector2i) -> EffectSpawnData:
    if not game_config or not game_config:
        return null
    
    var effect_data = EffectSpawnData.new(position, null)
    return effect_data
