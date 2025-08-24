class_name GameManager extends Node

@export var chess_board: ChessBoard
@export var piece_spawner: PieceSpawner


func _ready() -> void:
    chess_board.turn_over.connect(_on_turn_over)


func _on_turn_over(did_capture: bool) -> void:
    piece_spawner.spawn_random_piece(did_capture)
