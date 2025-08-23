class_name QueenRules extends PieceRules

func get_piece_type() -> String:
    return "Queen"


func get_legal_moves(board: ChessBoard, piece: PieceSpawnData) -> Array[Vector2i]:
    var moves: Array[Vector2i] = []

    # Queen combines Rook and Bishop movements: straight lines and diagonals
    var directions = [
        Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1),  # Rook moves
        Vector2i(1, 1), Vector2i(1, -1), Vector2i(-1, 1), Vector2i(-1, -1)  # Bishop moves
    ]
    
    for direction in directions:
        var current_pos = piece.position + direction
        
        while board.is_valid_position(current_pos):
            if board.is_position_occupied(current_pos):
                # Check if we can capture an opponent piece
                if board.is_position_occupied_by_opponent(current_pos, piece):
                    moves.append(current_pos)
                break  # Stop at first occupied square
            else:
                moves.append(current_pos)
                current_pos += direction

    return moves
