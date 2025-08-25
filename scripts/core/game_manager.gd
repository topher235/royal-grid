class_name GameManager extends Node

@export var chess_board: ChessBoard
@export var piece_spawner: PieceSpawner
@export var effect_spawner: EffectSpawner

var moves := 0
var score : = 0
var score_multiplier := 1
var score_multiplier_duration := 0  # forever


func _ready() -> void:
    chess_board.piece_captured.connect(_on_piece_captured)
    chess_board.turn_over.connect(_on_turn_over)


func _on_turn_over(did_capture: bool) -> void:
    moves += 1
    # Do end of turn effects - could involve effects expiring (duration running out)
    get_tree().call_group("effects", "on_end_turn")
    # Now spawn new things
    piece_spawner.spawn_random_piece(did_capture)
    effect_spawner.spawn_random_effect(moves, false)


func _on_piece_captured(piece_used: ChessPiece, piece_captured: ChessPiece) -> void:
    score += calculate_points(piece_used.data.points)
    Events.score_updated.emit(score)


func calculate_points(points: int) -> int:
    if score_multiplier_duration > 0:
        score_multiplier_duration -= 1
    
    if score_multiplier_duration < 0:
        score_multiplier = 1
    
    return points * score_multiplier


func update_points_multiplier(multiplier: int, duration: int) -> void:
    score_multiplier = multiplier
    score_multiplier_duration = duration


func reset_points_multiplier() -> void:
    score_multiplier = 1
    score_multiplier_duration = 0


func spawn_new_piece() -> void:
    piece_spawner.spawn_random_piece(false, true)
