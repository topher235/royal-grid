class_name ChessBoardAnimator extends Node

@export var chess_board: ChessBoard
@export var move_animation_easing: Tween.EaseType = Tween.EASE_OUT
@export var move_animation_transition: Tween.TransitionType = Tween.TRANS_QUAD


func _ready() -> void:
    # chess_board.piece_moved.connect(animate_piece_move)
    pass


func animate_piece_move(piece: ChessPiece, _from_pos: Vector2i, to_pos: Vector2i) -> bool:
    # Calculate world positions
    var game_config = chess_board.game_config
    var to_world_pos = Vector2(to_pos.y * game_config.tile_size, to_pos.x * game_config.tile_size)
    
    # Temporarily reparent the piece to the board for animation
    var original_position = piece.position
    var original_z_index = piece.z_index
    piece.z_index = 5
    
    await piece.animate_move_to(to_world_pos)
    
    # Reparent back to the original parent
    piece.position = original_position
    piece.z_index = original_z_index
    
    return true

    
func animate_board_rotation(direction: RotateSpecialEffect.RotationDirection) -> void:
    """
    Animates the rotation of the entire chess board.
    """
    var game_config = chess_board.game_config
    var grid_size = game_config.grid_size
    var tile_size = game_config.tile_size
    
    # create a tween for overall animation timing
    var main_tween = create_tween()
    main_tween.set_ease(Tween.EASE_IN_OUT)
    main_tween.set_trans(Tween.TRANS_QUAD)
    
    # play rotation sound
    SoundManager.play_ui_sound_with_pitch(Sounds.MOVE, 1.2)
    
    # animate each tile to its new position
    var animation_duration = 0.6
    var stagger_delay = 0.02
    
    for x in range(grid_size.x):
        for y in range(grid_size.y):
            var tile = chess_board.tiles[x][y]
            if tile:
                var new_pos = tile.grid_position
                var target_world_pos = Vector2(new_pos.y * tile_size, new_pos.x * tile_size)
                # create individual tween for this tile
                var tile_tween = create_tween()
                tile_tween.set_ease(Tween.EASE_OUT)
                
                # animate position with slight arc for visual appeal
                tile_tween.tween_property(tile, "position", target_world_pos, animation_duration)
                
                # Add subtle scale effect for tiles that are moving
                var og_scale = tile.scale
                tile_tween.parallel().tween_property(tile, "scale", og_scale * 1.1, animation_duration * 0.3)
                tile_tween.parallel().tween_property(tile, "scale", og_scale, animation_duration * 0.7).set_delay(animation_duration * 0.3)
            
                # Add slight rotation to tile for extra flair
                var rotation_angle = 15.0 if direction == RotateSpecialEffect.RotationDirection.CLOCKWISE else -15.0
                tile_tween.parallel().tween_property(tile, "rotation_degrees", rotation_angle, animation_duration * 0.3)
                tile_tween.parallel().tween_property(tile, "rotation_degrees", 0.0, animation_duration * 0.7).set_delay(animation_duration * 0.3)
    
    # wait for longest animation to complete
    await get_tree().create_timer(animation_duration + (grid_size.x * grid_size.y * stagger_delay)).timeout
