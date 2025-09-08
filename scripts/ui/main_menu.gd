class_name MainMenu extends Control

signal change_screen
signal scene_changed(to_path: String)

@export var continue_game_button: MainMenuButton
@export var play_game_button: MainMenuButton
@export var settings_button: MainMenuButton
@export var shop_button: MainMenuButton


@export var settings_piece: Control
@export var shop_piece: Control
@export var stats_piece: Control
@export var animation_player: AnimationPlayer


func _ready() -> void:
    pass
    # continue_game_button.label.text = "Continue Game"
    # continue_game_button.pressed.connect(_on_continue_game_button_pressed)

    # play_game_button.label.text = "Play Game"
    # play_game_button.pressed.connect(_on_play_game_button_pressed)
    
    # settings_button.label.text = "Settings"
    # settings_button.pressed.connect(_on_settings_button_pressed)

    # shop_button.label.text = "Shop"
    # shop_button.pressed.connect(_on_shop_button_pressed)

    # update_menu_buttons()

    # animation_player.play("open_title_scroll")
    # animation_player.queue("fade_in_menu_box")


func update_menu_buttons() -> void:
    """
    Updates the visibility of menu buttons based on save state.
    """
    var has_active_game = SaveManager.has_active_game()
    # TODO: there is probably a better way
    #  we want to set this button as visible if there is an active game
    #  but the animation player will set it to visible as part of the animation
    #  maybe the animation player should call a method in this script that tweens its fade-in animation
    #  which can use the has_active_game
    if not has_active_game:
        continue_game_button.queue_free()
    # continue_game_button.visible = has_active_game

    if has_active_game:
        play_game_button.label.text = "New Game"
    else:
        play_game_button.label.text = "Play Game"


func _on_play_game_button_pressed() -> void:
    Log.info(self, "Start a new game")
    SaveManager.clear_active_game()
    scene_changed.emit("res://scenes/ui/game_ui.tscn")


func _on_continue_game_button_pressed() -> void:
    Log.info(self, "Continue active game")
    scene_changed.emit("res://scenes/ui/game_ui.tscn")


func _on_settings_gui_input(event: InputEvent) -> void:
    if event is InputEventMouseButton and event.is_pressed():
        print("settings")
        animation_player.play("to_settings")
        await animation_player.animation_finished
        animation_player.play_backwards("to_settings")


func _on_shop_gui_input(event: InputEvent) -> void:
    if event is InputEventMouseButton and event.is_pressed():
        print("shop")
        animation_player.play("to_shop")
        await animation_player.animation_finished
        animation_player.play_backwards("to_shop")


func _on_stats_gui_input(event: InputEvent) -> void:
    if event is InputEventMouseButton and event.is_pressed():
        print("stats")
        animation_player.play("to_stats")
        await animation_player.animation_finished
        animation_player.play_backwards("to_stats")


func get_scene_data() -> Dictionary:
    return {}


func set_scene_data(value: Dictionary):
    pass
