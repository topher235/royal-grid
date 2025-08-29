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
    get_tree().call_group("tiles", "on_end_turn")
    if score_multiplier_duration > 0:
        score_multiplier_duration -= 1
        if score_multiplier_duration <= 0:
            reset_points_multiplier()
    
    # Now spawn new things
    piece_spawner.spawn_random_piece(did_capture)
    effect_spawner.spawn_random_effect(moves, false)


func _on_piece_captured(piece_used: ChessPiece, _piece_captured: ChessPiece) -> void:
    score_points(piece_used.data.points)


func score_points(points: int) -> void:
    score += calculate_points(points)
    Events.score_updated.emit(score)


func calculate_points(points: int) -> int:
    return points * score_multiplier


func update_points_multiplier(multiplier: int, duration: int) -> void:
    score_multiplier += multiplier
    score_multiplier_duration += duration
    Events.mult_updated.emit(score_multiplier)


func reset_points_multiplier() -> void:
    score_multiplier = 1
    score_multiplier_duration = 0
    Events.mult_updated.emit(score_multiplier)


func spawn_new_piece() -> void:
    piece_spawner.spawn_random_piece(false, true)


func spawn_new_piece_from_data(piece_data: PieceSpawnData) -> void:
    piece_spawner.spawn_from_data(piece_data)


func remove_effect(special_effect: SpecialEffect) -> void:
    for effect in get_tree().get_nodes_in_group("effects"):
        if effect.special_effect == special_effect:
            chess_board.remove_effect(effect.grid_position)
            return


func destroy_at_position(pos: Vector2i, _perform_scoring: bool) -> void:
    if not chess_board.does_position_have_piece(pos):
        return
    
    var piece = chess_board.remove_piece(pos)
    if piece:
        piece.animate_capture()
        # TODO: might want a slight delay here?
        score_points(piece.data.points)


func freeze_tile(pos: Vector2i, duration: int) -> void:
    var tile = chess_board.retrieve_tile_at_position(pos)
    tile.freeze(duration)
