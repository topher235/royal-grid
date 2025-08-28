class_name MainMenu extends Control

@export var play_game_button: MainMenuButton
@export var settings_button: MainMenuButton
@export var shop_button: MainMenuButton

@export var animation_player: AnimationPlayer


func _ready() -> void:
    play_game_button.label.text = "Play Game"
    play_game_button.pressed.connect(_on_play_game_button_pressed)
    
    settings_button.label.text = "Settings"
    settings_button.pressed.connect(_on_settings_button_pressed)

    shop_button.label.text = "Shop"
    shop_button.pressed.connect(_on_shop_button_pressed)

    animation_player.play("open_title_scroll")
    animation_player.queue("fade_in_menu_box")



func _on_play_game_button_pressed() -> void:
    print("play game")


func _on_settings_button_pressed() -> void:
    print("settings")


func _on_shop_button_pressed() -> void:
    print("shop")
