class_name PieceSpawnRules extends Resource

@export var spawn_pieces_on_empty_turn := true
@export var max_pieces_on_board := 25
@export var piece_spawn_chance := 0.4  # Used if a player captured a piece last turn
@export var piece_type_weights: Dictionary = {
    "pawn": 1.0,
    "rook": 0.15,
    "knight": 0.15,
    "bishop": 0.15,
    "queen": 0.1,
    "king": 0.05,
}
