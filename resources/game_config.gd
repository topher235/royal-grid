class_name GameConfig extends Resource

@export var map: Map
@export var tile_size: int = 40
@export var starting_pieces: Array[PieceSpawnData] = []
@export var num_random_pieces: int = 3
@export var piece_spawn_rules: PieceSpawnRules
@export var game_rules: GameRules
@export var character: BaseCharacter
@export var cosmetic: BaseCosmetic

# Whether or not to add a chess timer
# game is lost when it reaches 0
@export var use_chess_timer := false
# The number of seconds the chess timer starts with
@export var chess_timer_start_seconds := 25

var grid_size: Vector2i:
    get:
        return map.grid_size if map else Vector2i(4, 4)


func _init() -> void:
    if not piece_spawn_rules:
        piece_spawn_rules = PieceSpawnRules.new()
    if not game_rules:
        game_rules = GameRules.new()
    if not map:
        map = Map.create_default_map()
        
        
func apply_modifiers() -> void:
    """
    Applies general modifiers to PieceSpawnRules.
    """
    if piece_spawn_rules and character:
        piece_spawn_rules.apply_rules_modifiers(character.modifiers)
    else:
        Log.error(self, "Missing piece_spawn_rules or character")


static func default_game() -> GameConfig:
    var this = GameConfig.new()
    this.map = load("res://resources/maps/map_1.tres")

    var white_pawn = PieceSpawnData.new()
    white_pawn.piece_type = PieceSpawnData.PieceType.PAWN
    white_pawn.position = Vector2i(1, 3)
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


func get_active_tile_positions() -> Array[Vector2i]:
    if not map:
        return []
    return map.get_active_tiles()
    
    
func get_piece_type_weights(moves: int) -> Dictionary:
    """
    Retrieve the modified piece type weights, applying all available modifiers.
    """
    var modifiers := character.modifiers
    return piece_spawn_rules.get_piece_type_weights(moves, modifiers)
