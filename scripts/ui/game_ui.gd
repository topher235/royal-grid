class_name GameUI extends Node2D

const CHESS_PIECE = preload("res://scenes/pieces/chess_piece.tscn")

@export var game_board: ChessBoard
@export var mult_label: Label
@export var score_label: Label
@export var next_piece_container: PanelContainer
@export var background_sprite: TextureRect

var score_tween: Tween
var score_queue: Array[int]
var current_score := 0
var current_mult := 1


func _ready() -> void:
    score_label.text = "" + str(current_score)
    mult_label.text = "x" + str(current_mult)

    Events.score_updated.connect(_on_score_updated)
    Events.mult_updated.connect(_on_mult_updated)
    Events.next_piece_is_spawning.connect(_on_next_piece_is_spawning)
    Events.next_piece_generated.connect(_on_next_piece_generated)

    if game_board:
        game_board.game_over.connect(_on_game_over)

    load_game_state()


func load_game_state() -> void:
    """
    Loads the game state from SaveManager if available, otherwise starts a new game.
    """
    var active_game = SaveManager.retrieve_active_game()
    if active_game:
        Log.info(self, "Loading saved game")
        if game_board:
            game_board.load_game_state(active_game)
    else:
        Log.info(self, "Starting new game")
        if game_board:
            game_board.load_new_game()
    
    load_map_background()


func load_map_background() -> void:
    """
    Load the background sprite from the current map.
    """
    if game_board and game_board.game_config and game_board.game_config.map:
        var map = game_board.game_config.map
        if map.background_sprite and background_sprite:
            background_sprite.texture = map.background_sprite
            Log.info(self, "Loaded background for map: " + map.map_name)


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
    # TODO: open modal
    pass


func _on_score_updated(new_score: int) -> void:
    score_queue.append(new_score)
    update_score_label()


func _on_mult_updated(new_mult: int) -> void:
    current_mult = new_mult
    mult_label.text = "x" + str(current_mult)


func update_score_label() -> void:
    if score_queue.is_empty():
        return
    
    if score_tween and score_tween.is_running():
        await score_tween.finished
    
    var target_score = score_queue.pop_front()
    if target_score <= current_score:
        current_score = target_score
        score_label.text = "" + str(current_score)
        return
    
    score_tween = create_tween()
    

    var steps = target_score - current_score
    var total_time = 0.3
    var step_delay = float(total_time / steps)  # 0.1
    var min_pitch = 0.9
    var max_pitch = 1.1
    for i in range(1, steps + 1):
        score_tween.parallel().tween_callback(func():
            current_score += 1
            var pitch = min_pitch + (randf() * (max_pitch - min_pitch))
            SoundManager.play_ui_sound_with_pitch(Sounds.TYPING, pitch)
            score_label.text = "" + str(current_score)
        ).set_delay((step_delay * i))

    await score_tween.finished
    current_score = target_score


func _on_next_piece_is_spawning() -> void:
    var piece: ChessPiece = next_piece_container.get_child(0)
    piece.fadeout()


func _on_next_piece_generated(piece_data: PieceSpawnData) -> void:
    var piece: ChessPiece = CHESS_PIECE.instantiate() as ChessPiece
    piece.data = piece_data
    piece.animate_spawn()
    next_piece_container.add_child(piece)


func get_scene_data() -> Dictionary:
    return {}


func set_scene_data(value: Dictionary):
    pass
