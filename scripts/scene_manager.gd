class_name SceneManager extends Node

@export var overlay: ColorRect
@export var animation_player: AnimationPlayer

var current_scene


func _ready() -> void:
    current_scene = get_child(0)
    current_scene.connect("scene_changed", _on_scene_changed)


func _on_scene_changed(to_path: String) -> void:
    var data = current_scene.get_scene_data()

    # Play transition in (fade to black)
    animation_player.play("checkerboard_swipe")
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
    animation_player.play("checkerboard_fadeout")
    await animation_player.animation_finished

    # Reset for next transition
    animation_player.play("RESET")
