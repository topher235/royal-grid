class_name KingRules extends PieceRules


func get_piece_type() -> String:
    return "King"


func get_legal_moves(board: ChessBoard, piece: PieceSpawnData) -> Array[Vector2i]:
    var moves: Array[Vector2i] = []

    # King moves one square in any direction
    var directions = [
        Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1),  # Straight
        Vector2i(1, 1), Vector2i(1, -1), Vector2i(-1, 1), Vector2i(-1, -1)  # Diagonal
    ]
    
    for direction in directions:
        var target_pos = piece.position + direction
        if board.is_valid_position(target_pos):
            if not board.is_position_occupied(target_pos):
                moves.append(target_pos)
            elif board.is_position_occupied_by_opponent(target_pos, piece):
                moves.append(target_pos)
            # elif board.can_piece_move_to_tile(target_pos):
            #     moves.append(target_pos)
    
    return moves
