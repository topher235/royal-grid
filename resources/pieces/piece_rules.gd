class_name PieceRules extends Resource


func get_piece_type() -> String:
    return "Base"


func get_legal_moves(_board: ChessBoard, _piece: PieceSpawnData) -> Array[Vector2i]:
    return []


func can_move_to(board: ChessBoard, pos: Vector2i, piece: PieceSpawnData) -> bool:
    var legal_moves = get_legal_moves(board, piece)
    return pos in legal_moves
