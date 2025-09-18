class_name GameManager extends Node

@export var chess_board: ChessBoard
@export var piece_spawner: PieceSpawner
@export var effect_spawner: EffectSpawner

var moves := 0
var score := 0
var score_multiplier := 1
var score_multiplier_duration := 0  # forever
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
    
    # Do end of turn effects - could involve effects expiring (duration running out)
    get_tree().call_group("effects", "on_end_turn")
    get_tree().call_group("tiles", "on_end_turn")
    if score_multiplier_duration > 0:
        score_multiplier_duration -= 1
        if score_multiplier_duration <= 0:
            reset_points_multiplier()
    
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
    # update the PlayerStats, tracking what piece was just captured
    if current_game_stats:
        current_game_stats.update_captured(piece_captured)
    
    # if we're configured to have a chess timer, then add time to it and let UI components know it's updated
    if game_config and game_config.use_chess_timer:
        chess_timer_time_left += 5
        Events.chess_timer_updated.emit(chess_timer_time_left)
    
    # update the player's score
    score_points(piece_used.data.points)


func score_points(points: int) -> void:
    score += calculate_points(points)
    if current_game_stats:
        current_game_stats.update_score(score)
    Events.score_updated.emit(score)


func calculate_points(points: int) -> int:
    return points * score_multiplier


func update_points_multiplier(multiplier: int, duration: int) -> void:
    score_multiplier += multiplier
    score_multiplier_duration += duration
    if current_game_stats:
        current_game_stats.update_multiplier(score_multiplier)
    Events.mult_updated.emit(score_multiplier)


func reset_points_multiplier() -> void:
    score_multiplier = 1
    score_multiplier_duration = 0
    Events.mult_updated.emit(score_multiplier)


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
    SaveManager.clear_active_game()
    var player_stats = SaveManager.retrieve_stats()
    # Merge long-term stats with this game's stats
    player_stats.end_game(current_game_stats)
    SaveManager.update_stats(player_stats)

    # Emit signal to UI world
    chess_board.game_over.emit(score)


func retrieve_next_piece() -> PieceSpawnData:
    return piece_spawner.retrieve_next_piece()


func set_next_piece(spawn_data: PieceSpawnData) -> void:
    piece_spawner.set_next_piece(spawn_data)


func autosave() -> void:
    var active_game = chess_board.get_game_state()
    SaveManager.update_active_game(active_game)
