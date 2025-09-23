class_name PauseModal extends Control

signal closed
signal game_exit_requested
    
@export_group("Nodes")
@export var sound_toggle: CheckButton
@export var music_toggle: CheckButton
@export var animation_player: AnimationPlayer


func open() -> void:
    sound_toggle.button_pressed = UserConfig.get_setting(UserConfig.SOUND)
    music_toggle.button_pressed = UserConfig.get_setting(UserConfig.MUSIC)
    
    animation_player.play("open")
    SoundManager.play_ui_sound(Sounds.MODAL_OPEN)

    
func _on_close_button_pressed() -> void:
    animation_player.play_backwards("open")
    await animation_player.animation_finished
    SoundManager.play_ui_sound(Sounds.MODAL_CLOSE)
    closed.emit()


func _on_sound_button_toggled(toggled_on: bool) -> void:
    """
    Doing a bit of cheating with these settings. If toggled on, then turn
    the volume up, otherwise just turn the volume down to 0. This will appear as if
    sounds aren't playing, but they will be.

    If this is inefficient anywhere, we'll move to actually disabling playing sounds.
    """
    Log.info(self, "Sound toggled " + str(toggled_on))
    var volume = 1.0 if toggled_on else 0.0
    SoundManager.set_sound_volume(volume)
    # Save to file
    UserConfig.set_setting(UserConfig.SOUND, toggled_on)
    UserConfig.save_user_settings()


func _on_music_button_toggled(toggled_on: bool) -> void:
    """
    Doing a bit of cheating with these settings. If toggled on, then turn
    the volume up, otherwise just turn the volume down to 0. This will appear
    like the music is off, but it won't be.

    If this proves to be inefficient, we'll move to actually turning the music off.
    """
    Log.info(self, "Music toggled " + str(toggled_on))
    var volume = 1.0 if toggled_on else 0.0
    SoundManager.set_music_volume(volume)
    # Save to file
    UserConfig.set_setting(UserConfig.MUSIC, toggled_on)
    UserConfig.save_user_settings()

    
func _on_exit_game_button_pressed() -> void:
    game_exit_requested.emit()
