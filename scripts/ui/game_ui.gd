class_name GameUI extends Node2D

signal scene_changed(to_path: String)

@export var game_board: ChessBoard
@export var animation_player: AnimationPlayer
@export var end_game_overlay: EndGameOverlay
@export var pause_modal: PauseModal

@export_group("Scoring")
@export var points_label: Label
@export var mult_label: Label
@export var score_label: Label
@export var final_score_label: Label

@export_group("Time Remaining")
@export var timer_container: Control
@export var time_left_label: Label
@export var hourglass_sprite: TextureRect

var score_tween: Tween
var score_queue: Array[int]
var old_score := 0
var current_score := 0
var current_mult := 1
var game_config: GameConfig
var continue_game := false


func _ready() -> void:
    score_label.text = "" + str(current_score)
    mult_label.text = "x" + str(current_mult)

    Events.points_scored.connect(_on_points_scored)
    Events.score_updated.connect(_on_score_updated)
    Events.mult_updated.connect(_on_mult_updated)
    if game_config and game_config.use_chess_timer:
        Events.chess_timer_updated.connect(_on_chess_timer_updated)
        # Animating the hourglass rotating in a circle
        var hourglass_tween: Tween = hourglass_sprite.create_tween()
        hourglass_tween.set_loops()
        hourglass_tween.tween_callback(
            func():
                var marker: Marker2D = hourglass_sprite.get_parent()
                var old_rotation := marker.rotation_degrees
                marker.rotation_degrees = wrapi(old_rotation + 45, 0, 360)
        ).set_delay(0.75)
    else:
        timer_container.hide()

    if game_board:
        game_board.game_over.connect(_on_game_over)
        if game_config:
            game_board.game_config = game_config

    load_game_state()


func load_game_state() -> void:
    """
    Loads the game state from SaveManager if available, otherwise starts a new game.
    """
    var active_game := SaveManager.retrieve_active_game()
    if active_game and continue_game:
        Log.info(self, "Loading saved game")
        if game_board:
            game_board.load_game_state(active_game)
    else:
        Log.info(self, "Starting new game")
        if game_board:
            game_board.load_new_game()


func save_current_game() -> void:
    """
    Saves the current game state to SaveManager.
    """
    if game_board:
        var active_game = game_board.get_game_state()
        SaveManager.update_active_game(active_game)
        Log.info(self, "Game saved")


func _on_game_over(final_score: int) -> void:
    """
    Called when the game ends. Clears the active game and updates stats.
    """
    final_score_label.text = final_score_label.text + str(final_score)
    animation_player.play("game_over")

    
func _on_points_scored(points: int) -> void:
    # These are points, sans multiplier
    points_label.text = str(points)
    get_tree().create_timer(1).timeout.connect(
        animate_counting_label.bind(points_label, points, 0)
    )


func _on_score_updated(new_score: int) -> void:
    # This is the new, final score, if the game were to end
    old_score = current_score
    current_score = new_score
    get_tree().create_timer(1).timeout.connect(
        animate_counting_label.bind(score_label, old_score, current_score)
    )


func _on_mult_updated(new_mult: int) -> void:
    current_mult = new_mult
    mult_label.text = str(current_mult)

    
func animate_counting_label(label: Label, from_num: int, to_num: int) -> void:
    """
    Utility function for animating a counting label. A "counting" label is one that rapidly increments its
    text from 1 number to another.
    
    Could be improved with a class-scoped tween, so we can have more control over the animations. For example,
    if a player scores more points while the label is counting, we might end up with 2 tweens affecting the
    same node.
    """
    # Determine whether we are counting up or down
    var greater := maxi(from_num, to_num)
    var lesser := mini(from_num, to_num)
    var increment_direction := 1 if to_num - from_num >= 0 else -1
    # Configure the tween
    var tween: Tween = create_tween()
    var steps := greater - lesser
    var total_time := 0.3
    var step_delay := float(total_time / steps)
    var min_pitch := 0.9
    var max_pitch := 1.1
    var current_num := from_num
    for i in range(1, steps + 1):
        # we have to increment the current_num outside of the tween callback, otherwise
        # it will have a snapshot of what it was, and it will only increment 1x
        current_num += increment_direction
        tween.parallel().tween_callback(
            func():
                var pitch := min_pitch + (randf() * (max_pitch - min_pitch))
                SoundManager.play_ui_sound_with_pitch(Sounds.TYPING, pitch)
                label.text = "" + str(current_num)
        ).set_delay(step_delay * i)

    
func _on_chess_timer_updated(time_left: int) -> void:
    time_left_label.text = str(time_left)

    
func _on_pause_button_pressed() -> void:
    pause_modal.visible = true
    pause_modal.open()
    game_board.pause()
    pause_modal.closed.connect(_on_pause_menu_closed, CONNECT_ONE_SHOT)
    if not pause_modal.game_exit_requested.is_connected(_on_game_exit_requested):
        pause_modal.game_exit_requested.connect(_on_game_exit_requested)

        
func _on_pause_menu_closed() -> void:
    pause_modal.visible = false
    game_board.unpause()

        
func _on_game_exit_requested() -> void:
    game_board.save_active_game()
    scene_changed.emit("res://scenes/ui/main_menu.tscn")

    
func calculate_coins() -> void:
    var coins := CoinCalculator.calculate(current_score)
    end_game_overlay.coins = coins
    end_game_overlay.animate_coins()


func get_scene_data() -> Dictionary:
    return {}


func set_scene_data(value: Dictionary):
    game_config = value["game_config"]
    continue_game = value.get("continue", false)
