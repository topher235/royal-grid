class_name PieceAnimator extends Node

@export var piece: ChessPiece
@export var animation_player: AnimationPlayer
@export var is_animating := false
@export var animation_speed := 1.0
@export var move_animation_duration := 0.3
@export var capture_animation_duration := 0.3
@export var spawn_animation_duration := 0.3


func animate_move_to(target_world_pos: Vector2) -> void:
    if is_animating:
        return
    
    is_animating = true

    var tween = create_tween()
    tween.set_ease(Tween.EASE_OUT)
    tween.set_trans(Tween.TRANS_QUAD)

    # animate position
    tween.tween_property(
        piece, "global_position", target_world_pos, move_animation_duration
    ).set_delay(capture_animation_duration * 0.5)

    # add a subtle scale animation for visual feedback
    var original_scale = piece.scale
    tween.parallel().tween_property(piece, "scale", original_scale * 1.1, move_animation_duration * 0.3)
    tween.parallel().tween_property(piece, "scale", original_scale, move_animation_duration * 0.7).set_delay(move_animation_duration * 0.3)

    await tween.finished
    is_animating = false


func animate_capture() -> void:
    animation_player.play("capture")
    animation_player.animation_finished.connect(piece.queue_free)


func animate_spawn() -> void:
    animation_player.play("spawn")
