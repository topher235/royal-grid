class_name SceneManager extends Node

enum TransitionType {
    CHECKERBOARD,
    FADE
}

@export var checkerboard_overlay: ColorRect
@export var fade_overlay: ColorRect
@export var animation_player: AnimationPlayer

var current_scene


func _ready() -> void:
    current_scene = get_child(0)
    current_scene.connect("scene_changed", _on_scene_changed)


func _on_scene_changed(to_path: String, transition_type: TransitionType = TransitionType.CHECKERBOARD) -> void:
    var data = current_scene.get_scene_data()

    # Determine animations based on transition type
    var fade_in_animation: String
    var fade_out_animation: String

    match transition_type:
        TransitionType.CHECKERBOARD:
            fade_in_animation = "checkerboard_swipe"
            fade_out_animation = "checkerboard_fadeout"
        TransitionType.FADE:
            fade_in_animation = "fade_in"
            fade_out_animation = "fade_out"

    # Play transition in (cover screen)
    animation_player.play(fade_in_animation)
    await animation_player.animation_finished

    # Prepare and add next scene
    var next_scene = load(to_path).instantiate()
    next_scene.set_scene_data(data)
    add_child(next_scene)
    next_scene.connect("scene_changed", _on_scene_changed)

    # Clean up old scene
    if current_scene != null:
        current_scene.queue_free()
    current_scene = next_scene

    # Play transition out (reveal new scene)
    animation_player.play(fade_out_animation)
    await animation_player.animation_finished

    # Reset for next transition
    animation_player.play("RESET")
