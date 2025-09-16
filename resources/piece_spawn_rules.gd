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
@export var spawn_frequency := 1


func get_piece_type_weights(modifiers: Array[BaseModifier]) -> Dictionary:
    """
    Retrieves a modified version of the default piece weights, applying each instance
    of SpawnRulesModifier. Ignores other modifiers.
    """
    var final_value := piece_type_weights.duplicate()
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
    