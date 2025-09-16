class_name PawnRules extends PieceRules


func get_piece_type() -> String:
    return "Pawn"


func get_legal_moves(board: ChessBoard, piece: PieceSpawnData) -> Array[Vector2i]:
    var moves: Array[Vector2i] = []

    # determine movement direction based on color
    var direction = -1 if piece.color else 1  # white moves up (-1), Black moves down (1)

    # Forward movement
    var forward_pos = piece.position + Vector2i(direction, 0)
    if board.is_valid_position(forward_pos) and not board.does_position_have_piece(forward_pos):
        moves.append(forward_pos)

    # Diagonal captures
    var capture_directions = [Vector2i(direction, -1), Vector2i(direction, 1)]
    for capture_dir in capture_directions:
        var capture_pos = piece.position + capture_dir
        if board.is_valid_position(capture_pos) and board.is_position_occupied_by_opponent(capture_pos, piece):
            moves.append(capture_pos)
    
    return moves
