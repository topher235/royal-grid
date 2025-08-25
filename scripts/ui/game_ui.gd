class_name GameUI extends Node2D

@export var game_board: ChessBoard
@export var score_label: Label

var score_tween: Tween
var score_queue: Array[int]
var current_score := 0


func _ready() -> void:
    Events.score_updated.connect(_on_score_updated)


func _on_score_updated(new_score: int) -> void:
    score_queue.append(new_score)
    update_score_label()


func update_score_label() -> void:
    if score_tween and score_tween.is_running():
        await score_tween.finished
    
    var target_score = score_queue.pop_front()
    if target_score <= current_score:
        current_score = target_score
        score_label.text = "Score: " + str(current_score)
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
            score_label.text = "Score: " + str(current_score)
        ).set_delay((step_delay * i))

    await score_tween.finished
    current_score = target_score
