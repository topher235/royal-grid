class_name MainMenu extends Control

signal scene_changed(to_path: String)

const SETTINGS_SCENE = preload("res://scenes/settings/settings_modal.tscn")
const STATS_SCENE = preload("res://scenes/stats/stats_modal.tscn")

@export var continue_game_button: TextureButton
@export var play_game_button: TextureButton

@export var modal_container: Node
@export var settings_piece: Control
@export var shop_piece: Control
@export var stats_piece: Control
@export var animation_player: AnimationPlayer


func _ready() -> void:
    update_menu_buttons()
    # Set up menu items `gui_input` signal to play a sound and animation when pressed
    settings_piece.gui_input.connect(_on_menu_item_gui_input.bind("to_settings"))
    shop_piece.gui_input.connect(_on_menu_item_gui_input.bind("to_shop"))
    stats_piece.gui_input.connect(_on_menu_item_gui_input.bind("to_stats"))


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


func _on_play_button_pressed() -> void:
    Log.info(self, "Start a new game")
    SaveManager.clear_active_game()
    scene_changed.emit("res://scenes/config_loadout/config_loadout.tscn")


func _on_continue_button_pressed() -> void:
    Log.info(self, "Continue active game")
    scene_changed.emit("res://scenes/ui/game_ui.tscn")


func _on_menu_item_gui_input(event: InputEvent, animation_name: String) -> void:
    if event is InputEventMouseButton and event.is_pressed():
        SoundManager.play_ui_sound(Sounds.HOVER)
        animation_player.play(animation_name)


func destroy_modal_children() -> void:
    for child in modal_container.get_children():
        child.queue_free()


func close_modal(animation_name: String) -> void:
    destroy_modal_children()
    animation_player.play_backwards(animation_name)


func open_modal(modal_type: String) -> void:
    """
    Instantiates a modal scene based on the modal_type provided and adds it as a child
    to the modal container node. Plays the modal's open animation and connects the backwards
    animation to its `closed` signal.
    """
    # Check if we're playing backwards
    # a negative speed means playing in reverse
    # if this becomes hacky, we might want separate "from_X" animations that omit this function call
    if animation_player.current_animation_position > 0 and animation_player.get_playing_speed() < 0:
        return  # Don't open modal when reversing
    
    Log.info(self, "open_modal opening " + modal_type)
    destroy_modal_children()

    var scene = null
    var animation_name = ""
    match modal_type:
        "settings":
            scene = SETTINGS_SCENE.instantiate()
            animation_name = "to_settings"
        "shop":
            # scene = SHOP_SCENE.instantiate()
            # animation_name = "to_shop"
            Log.error(self, "open_modal 'shop' branch needs to be implemented")
        "stats":
            scene = STATS_SCENE.instantiate()
            animation_name = "to_stats"
        _:
            Log.error(self, "open_modal did not match branch " + modal_type)
    
    if scene and animation_name:
        modal_container.add_child(scene)
        scene.open()
        scene.closed.connect(close_modal.bind(animation_name))


func play_move_sound() -> void:
    SoundManager.play_ui_sound(Sounds.MOVE)


func get_scene_data() -> Dictionary:
    return {}


func set_scene_data(value: Dictionary):
    pass
