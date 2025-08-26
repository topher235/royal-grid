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
    var to_world_pos = Vector2(to_pos.x * game_config.tile_size, to_pos.y * game_config.tile_size)
    
    # Temporarily reparent the piece to the board for animation
    var original_position = piece.position
    var original_z_index = piece.z_index
    piece.z_index = 5
    
    await piece.animate_move_to(to_world_pos)
    
    # Reparent back to the original parent
    piece.position = original_position
    piece.z_index = original_z_index
    
    return true
