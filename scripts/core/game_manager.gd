class_name GameManager extends Node

@export var chess_board: ChessBoard
@export var piece_spawner: PieceSpawner
@export var effect_spawner: EffectSpawner

var moves := 0
var captures_in_a_row := 0
var score := 0

# Multiplier stats
var base_multiplier := 1
var combo_multiplier := 0
var effect_multiplier := 0
var effect_multiplier_duration := 0  # forever

var current_game_stats: PlayerStats
var game_config: GameConfig

var chess_timer_time_left: int
var timer: Timer


func _ready() -> void:
    current_game_stats = PlayerStats.new()
    chess_board.piece_captured.connect(_on_piece_captured)
    chess_board.turn_over.connect(_on_turn_over)
    chess_board.new_game.connect(_on_new_game)

    
func _on_new_game() -> void:
    get_tree().create_timer(0.5).timeout.connect(_debounced_new_game_setup)

    
func _debounced_new_game_setup() -> void:
    """
    Create a chess timer if necessary.
    """
    if game_config and game_config.use_chess_timer:
        chess_timer_time_left = game_config.chess_timer_start_seconds
        timer = Timer.new()
        timer.wait_time = 1
        timer.one_shot = false  # run forever
        timer.autostart = true
        timer.timeout.connect(_on_chess_timer_timeout)
        add_child(timer)
        Events.chess_timer_updated.emit(chess_timer_time_left)

        
func _on_chess_timer_timeout() -> void:
    """
    Decrement the time left and if the time left is 0 then the game is over.
    """
    chess_timer_time_left -= 1
    Events.chess_timer_updated.emit(chess_timer_time_left)
    if chess_timer_time_left <= 0:
        end_game()


func _on_turn_over(did_capture: bool) -> void:
    moves += 1
    if current_game_stats:
        current_game_stats.update_moves(moves)
    
    if not did_capture:
        captures_in_a_row = 0
        update_combo_mult()
    
    # Do end of turn effects - could involve effects expiring (duration running out)
    get_tree().call_group("effects", "on_end_turn")
    get_tree().call_group("tiles", "on_end_turn")
    if effect_multiplier_duration > 0:
        effect_multiplier_duration -= 1
        if effect_multiplier_duration <= 0:
            # duration ran out, reset to 0
            update_effects_mult(0, 0)
    
    # Now spawn new things
    piece_spawner.end_turn(did_capture)
    effect_spawner.spawn_random_effect(moves, false)

    # Auto-save after each turn
    if chess_board:
        # Using call_deferred in case nodes are queued to be freed
        autosave.call_deferred()
    
    if is_game_over():
        end_game()


func _on_piece_captured(piece_used: ChessPiece, piece_captured: ChessPiece) -> void:
    captures_in_a_row += 1
    update_combo_mult()
    
    # update the PlayerStats, tracking what piece was just captured
    if current_game_stats:
        current_game_stats.update_captured(piece_captured)
    
    # if we're configured to have a chess timer, then add time to it and let UI components know it's updated
    if game_config and game_config.use_chess_timer:
        chess_timer_time_left += 5
        Events.chess_timer_updated.emit(chess_timer_time_left)
    
    # update the player's score
    score_points(piece_used.data.points)

    
func get_score_multiplier() -> int:
    return base_multiplier + combo_multiplier + effect_multiplier


func score_points(points: int) -> void:
    var calculated_points := calculate_points(points)
    score += calculated_points
    if current_game_stats:
        current_game_stats.update_score(score)
    # 1 event for the ui to know how many points were scored in this move
    Events.points_scored.emit(points)
    # 1 event for the ui to know what the actual score is, including mult
    Events.score_updated.emit(score)


func calculate_points(points: int) -> int:
    return points * get_score_multiplier()

    
func update_combo_mult() -> void:
    if captures_in_a_row < 6:
        combo_multiplier = captures_in_a_row
    else:
        combo_multiplier = 5
    
    if current_game_stats:
        current_game_stats.update_multiplier(get_score_multiplier())
    Events.mult_updated.emit(get_score_multiplier())


func update_effects_mult(multiplier: int, duration: int) -> void:
    effect_multiplier += multiplier
    effect_multiplier_duration += duration
    if current_game_stats:
        current_game_stats.update_multiplier(get_score_multiplier())
    Events.mult_updated.emit(get_score_multiplier())


func spawn_new_piece() -> void:
    piece_spawner.spawn_new_piece()


func spawn_next_piece() -> void:
    piece_spawner.spawn_next_piece(false, true)


func spawn_new_piece_from_data(piece_data: PieceSpawnData, excluding_positions: Array = []) -> void:
    piece_spawner.spawn_from_data(piece_data, excluding_positions)


func remove_effect(special_effect: SpecialEffect) -> void:
    for effect in get_tree().get_nodes_in_group("effects"):
        if effect.special_effect == special_effect:
            chess_board.remove_effect(effect.grid_position)
            return


func destroy_at_position(pos: Vector2i, _perform_scoring: bool) -> void:
    if not chess_board.does_position_have_piece(pos):
        return
    
    var piece = chess_board.remove_piece(pos)
    if piece:
        Log.info(self, "found " + str(piece.data.piece_type) + " at " + str(pos))
        piece.animate_capture()
        score_points(piece.data.points)


func freeze_tile(pos: Vector2i, duration: int) -> void:
    var tile = chess_board.retrieve_tile_at_position(pos)
    tile.freeze(duration)


func spawn_effect_from_data(spawn_data: EffectSpawnData) -> void:
    effect_spawner.spawn_from_data(spawn_data)


func is_game_over() -> bool:
    """
    The game is over if any of these conditions are met:
        - all pieces have no legal moves
    """
    var legal_move_exists := false
    for row in chess_board.pieces:
        for piece in row:
            if not piece is ChessPiece:
                continue
            # we only need to find 1 piece with legal moves, so exit once we find one
            if piece.get_legal_moves().size() > 0:
                legal_move_exists = true
                break
        if legal_move_exists:
            break
    
    var all_conditions: Array[bool] = [
        not legal_move_exists,  # semantically, our lose condition is "no" legal moves
    ]
    # if ANY condition is true then the game is over
    return true in all_conditions


func end_game() -> void:
    """
    Ends the current game and clears the active game from save data.
    """
    # Other managers should handle their own end of game logic
    # like stopping timers
    piece_spawner.end_game()
    
    if timer:
        timer.stop()
    
    SaveManager.clear_active_game()
    var player_stats = SaveManager.retrieve_stats()
    # Merge long-term stats with this game's stats
    player_stats.end_game(current_game_stats)
    SaveManager.update_stats(player_stats)

    # Emit signal to UI world
    chess_board.game_over.emit(score)


func retrieve_next_pieces() -> Array[PieceSpawnData]:
    return piece_spawner.retrieve_next_pieces()


func set_next_pieces(spawn_data: Array[PieceSpawnData]) -> void:
    piece_spawner.set_next_pieces(spawn_data)


func autosave() -> void:
    var active_game = chess_board.get_game_state()
    SaveManager.update_active_game(active_game)
    
    
func pause() -> void:
    if timer:
        timer.set_paused(true)
    piece_spawner.pause()

    
func unpause() -> void:
    if timer:
        timer.set_paused(false)
    piece_spawner.unpause()
