class_name SceneManager extends Node

var current_scene


func _ready() -> void:
    current_scene = get_child(0)
    current_scene.connect("scene_changed", _on_scene_changed)


func _on_scene_changed(to_path: String) -> void:
    var data = current_scene.get_scene_data()

    var fade_duration = 0.25
    var tween = create_tween()
    tween.parallel().tween_property(
        current_scene, "modulate:a", 0.0, fade_duration
    ).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

    var next_scene = load(to_path).instantiate()
    next_scene.set_scene_data(data)
    next_scene.modulate.a = 0

    tween.parallel().tween_property(next_scene, "modulate:a", 1.0, fade_duration).set_delay(fade_duration)

    add_child.call_deferred(next_scene)
    next_scene.connect("scene_changed", _on_scene_changed)

    await tween.finished

    if current_scene != null:
        current_scene.queue_free()
    current_scene = next_scene
