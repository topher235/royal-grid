class_name PieceSpawnRules extends Resource

@export var spawn_pieces_on_empty_turn := true
@export var max_pieces_on_board := 16
@export var piece_spawn_chance := 0.4  # Used if a player captured a piece last turn
@export var piece_type_weights: Dictionary = {
    "pawn": 0.3,
    "rook": 0.15,
    "knight": 0.15,
    "bishop": 0.15,
    # TODO: reduce queen and king weights greatly since SpawnEffect does that
    "queen": 0.1,
    "king": 0.05,
}
# for the RUSH game mode where pieces are spawned every X seconds
@export var spawn_on_timer := false
@export var spawn_frequency := 1  # in seconds


func apply_rules_modifiers(modifiers: Array[BaseModifier]) -> void:
    """
    Applies general rules modifiers.
    """
    for modifier in modifiers:
        if modifier is SpawnOnTimerModifier:
            spawn_on_timer = modifier.spawn_on_timer
            spawn_frequency = modifier.spawn_frequency_in_seconds

            
func get_progressive_weights(moves: int) -> Dictionary:
    """
    Calculate piece spawn weights that progressively increase difficulty. As moves increase,
    less flexible pieces, e.g. Pawns, become more common and more flexible pieces, e.g. Rooks,
    become more rare.
    
    Example weight progression:
    Moves	Pawn	Rook	Knight	Bishop	Queen	King
    0	    0.30	0.15	0.15	0.15	0.10	0.05
    20	    0.48	0.15	0.15	0.15	0.08	0.03
    40	    0.68	0.15	0.15	0.15	0.06	0.02
    60	    0.90	0.15	0.15	0.15	0.04	0.01
    """
    var piece_difficulty_factors := {
        "pawn": 0.8,
        "rook": 1.2,
        "knight": 1.0,  # baseline
        "bishop": 1.2,
        "queen": 1.5,
        "king": 1.0,
    }
    
    # difficulty scaling parameters
    var scaling_factor := 20.0  # Moves needed for a significant change
    var exponent := 1.5
    
    # calculate difficulty multiplier
    var difficulty_multiplier := 1.0 + pow(moves / scaling_factor, exponent)
    
    # apply progressive difficulty to each piece
    var progressive_weights := {}
    for piece_type in piece_type_weights.keys():
        var base_weight = piece_type_weights[piece_type]
        var difficulty_factor = piece_difficulty_factors[piece_type]
        
        # apply the equation: base * difficulty_multiplier * piece_factor
        var new_weight = base_weight * difficulty_multiplier * difficulty_factor
        progressive_weights[piece_type] = new_weight
    
    return progressive_weights
    

func get_piece_type_weights(moves: int, modifiers: Array[BaseModifier]) -> Dictionary:
    """
    Retrieves a modified version of the default piece weights, applying each instance
    of SpawnRulesModifier. Ignores other modifiers.
    """
    var final_value := get_progressive_weights(moves)
    for modifier in modifiers:
        if modifier is SpawnRulesModifier:
            final_value = apply_modifier(final_value, modifier as SpawnRulesModifier)
    return final_value

    
func apply_modifier(weights: Dictionary, modifier: SpawnRulesModifier) -> Dictionary:
    """
    Applies the modifier to the appropriate piece type based on what is defined
    on the modifier.
    """
    var weight_to_modify := ""
    match modifier.piece_type:
        PieceSpawnData.PieceType.PAWN: weight_to_modify = "pawn"
        PieceSpawnData.PieceType.ROOK: weight_to_modify = "rook"
        PieceSpawnData.PieceType.KNIGHT: weight_to_modify = "knight"
        PieceSpawnData.PieceType.BISHOP: weight_to_modify = "bishop"
        PieceSpawnData.PieceType.QUEEN: weight_to_modify = "queen"
        PieceSpawnData.PieceType.KING: weight_to_modify = "king"
    
    var new_value = weights[weight_to_modify]
    match modifier.operation:
        BaseModifier.Operation.ADD: new_value += modifier.value
        BaseModifier.Operation.SUBTRACT: new_value -= modifier.value
        BaseModifier.Operation.MULTIPLY: new_value *= modifier.value
        BaseModifier.Operation.SET: new_value = modifier.value
    
    weights[weight_to_modify] = new_value
    return weights
    