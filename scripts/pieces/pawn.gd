class_name Pawn extends ChessPiece

func get_legal_moves() -> Array[Vector2i]:
    var moves: Array[Vector2i] = []
    var board = get_tree().get_first_node_in_group("gameboard")

    # determine movement direction based on color
    var direction = -1 if piece_color else 1  # white moves up (-1), Black moves down (1)

    # Forward movement
    var forward_pos = grid_position + Vector2i(0, direction)
    if is_valid_position(forward_pos) and not is_position_occupied(board, forward_pos):
        moves.append(forward_pos)

    # Diagonal captures
    var capture_directions = [Vector2i(-1, direction), Vector2i(1, direction)]
    for capture_dir in capture_directions:
        var capture_pos = grid_position + capture_dir
        if is_valid_position(capture_pos) and is_position_occupied_by_opponent(board, capture_pos):
            moves.append(capture_pos)
    
    return moves


func is_valid_position(pos: Vector2i) -> bool:
    # Check if position is within 5x5 grid bounds
    return pos.x >= 0 and pos.x < 5 and pos.y >= 0 and pos.y < 5


func is_position_occupied(board: ChessBoard, pos: Vector2i) -> bool:
    return board.is_tile_occupied(pos)


func is_position_occupied_by_opponent(board: ChessBoard, pos: Vector2i) -> bool:
    var piece = board.get_piece_at(pos)
    # true if there is a piece and it doesn't match this piece's color
    return piece and piece.piece_color != piece_color


func get_piece_type() -> String:
    return "Pawn"
