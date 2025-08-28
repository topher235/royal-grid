extends Node

@export var sound: Sounds.SoundType


func _ready() -> void:
    var parent = get_parent()
    parent.pressed.connect(_on_parent_pressed)


func _on_parent_pressed() -> void:
    var audio_stream = Sounds.get_sound_from_type(sound)
    SoundManager.play_ui_sound(audio_stream)
