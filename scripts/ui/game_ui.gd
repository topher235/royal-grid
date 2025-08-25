class_name GameUI extends Node2D

@export var game_board: ChessBoard
@export var score_label: Label


func _ready() -> void:
    Events.score_updated.connect(_on_score_updated)


func _on_score_updated(new_score: int) -> void:
    score_label.text = "Score: " + var_to_str(new_score)
