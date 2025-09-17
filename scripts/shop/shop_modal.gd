extends Control

signal closed

@export_group("Nodes")
@export var animation_player: AnimationPlayer


func open() -> void:
    """
    Sets active tab to the bundles.
    """
    animation_player.play("open")
    SoundManager.play_ui_sound(Sounds.MODAL_OPEN)

    
func _on_close_button_pressed() -> void:
    animation_player.play_backwards("open")
    await animation_player.animation_finished
    SoundManager.play_ui_sound(Sounds.MODAL_CLOSE)
    closed.emit()
