extends Control

signal closed

@export_group("Nodes")
@export var sound_toggle: CheckButton
@export var music_toggle: CheckButton
@export var language_select: OptionButton
@export var animation_player: AnimationPlayer


func open() -> void:
    sound_toggle.button_pressed = UserConfig.get_setting(UserConfig.SOUND)
    music_toggle.button_pressed = UserConfig.get_setting(UserConfig.MUSIC)

    # TODO: initialize language options based on localization implementation
    for key in UserConfig.LANGUAGE_OPTIONS:
        var label = UserConfig.language_choices[key]
        language_select.add_item(label)
    var preferred_language = UserConfig.get_preferred_language()
    var selected_idx = -1
    if preferred_language == "automatic":
        selected_idx = 0
    else:
        selected_idx = UserConfig.LANGUAGE_OPTIONS.find(preferred_language)
    language_select.selected = selected_idx

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


func _on_language_item_selected(index: int) -> void:
    Log.info(self, "Language item selected " + str(index))
    var new_choice = UserConfig.LANGUAGE_OPTIONS[index]
    var old_choice = UserConfig.get_preferred_language()
    if new_choice != old_choice:
        UserConfig.set_setting(UserConfig.LANGUAGE, new_choice)
        TranslationServer.set_locale(new_choice)
    # Save to file
    UserConfig.save_user_settings()
