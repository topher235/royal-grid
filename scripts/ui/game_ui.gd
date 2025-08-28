class_name GameUI extends Node2D

const CHESS_PIECE = preload("res://scenes/pieces/chess_piece.tscn")

@export var game_board: ChessBoard
@export var score_label: Label
@export var next_piece_container: PanelContainer

var score_tween: Tween
var score_queue: Array[int]
var current_score := 0


func _ready() -> void:
    score_label.text = "" + str(current_score)

    Events.score_updated.connect(_on_score_updated)
    Events.next_piece_is_spawning.connect(_on_next_piece_is_spawning)
    Events.next_piece_generated.connect(_on_next_piece_generated)


func _on_score_updated(new_score: int) -> void:
    score_queue.append(new_score)
    update_score_label()


func update_score_label() -> void:
    if score_tween and score_tween.is_running():
        await score_tween.finished
    
    var target_score = score_queue.pop_front()
    if target_score <= current_score:
        current_score = target_score
        score_label.text = "" + str(current_score)
        return
    
    score_tween = create_tween()
    

    var steps = target_score - current_score
    var total_time = 0.3
    var step_delay = float(total_time / steps)  # 0.1
    var min_pitch = 0.9
    var max_pitch = 1.1
    for i in range(1, steps + 1):
        score_tween.parallel().tween_callback(func():
            current_score += 1
            var pitch = min_pitch + (randf() * (max_pitch - min_pitch))
            SoundManager.play_ui_sound_with_pitch(Sounds.TYPING, pitch)
            score_label.text = "" + str(current_score)
        ).set_delay((step_delay * i))

    await score_tween.finished
    current_score = target_score


func _on_next_piece_is_spawning() -> void:
    var piece: ChessPiece = next_piece_container.get_child(0)
    piece.fadeout()


func _on_next_piece_generated(piece_data: PieceSpawnData) -> void:
    var piece: ChessPiece = CHESS_PIECE.instantiate() as ChessPiece
    piece.data = piece_data
    piece.animate_spawn()
    next_piece_container.add_child(piece)
