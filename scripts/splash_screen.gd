class_name SplashScreen extends Control

signal loaded
signal change_screen
signal scene_changed(to_path: String)

@export var splash_container: Node
@export var reset_save: bool
@export var in_time := 0.25
@export var fade_in_time := 0.5
@export var pause_time := 0.2 # 1.0
@export var fade_out_time := 0.5
@export var out_time := 0.0

@onready var is_ready := false

var can_transition := false
var is_transition_started := false
var splash_screens := []


func _ready() -> void:
    get_screens()
    fade()
    change_screen.connect(_handle_change_screen)
    load_resources()


func get_screens() -> void:
    splash_screens = splash_container.get_children()
    for screen in splash_screens:
        screen.modulate.a = 0.0


func fade() -> void:
    for screen in splash_screens:
        var tween = create_tween()
        tween.tween_interval(in_time)
        tween.tween_property(screen, "modulate:a", 1.0, fade_in_time)
        tween.tween_interval(pause_time)
        tween.tween_property(screen, "modulate:a", 0.0, fade_out_time)
        tween.tween_interval(out_time)
        await tween.finished
    _handle_change_screen()


func load_resources() -> void:
    # GameState.load_game(reset_save)
    # UserConfig.load()
    is_ready = true


func _handle_change_screen() -> void:
    # We have a timer created that will set `can_transition` to force the user
    # to watch the logo for 1s
    # If the user presses multiple buttons, it could try to transition multiple times
    # so we track if the transition has started, to disable multiple attempts
    if not can_transition or is_transition_started:
        return
    
    if self.is_ready:
        scene_changed.emit("res://scenes/ui/main_menu.tscn")
        is_transition_started = true
    else:
        await get_tree().create_timer(0.1).timeout
        _handle_change_screen()


func _unhandled_input(event):
    if event.is_pressed():
        _handle_change_screen()


func get_scene_data() -> Dictionary:
    return {"source": "splash"}


func set_scene_data(data: Dictionary) -> void:
    loaded.emit()
    pass


func _on_gui_input(event: InputEvent) -> void:
    if event.is_pressed():
        _handle_change_screen()


func _on_timer_timeout() -> void:
    """
    Force the user to watch the logo for 1s
    """
    can_transition = true
