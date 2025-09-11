class_name PlayerStats extends Resource

# Core gameplay
var num_games_played := 0
var best_score := 0
var total_score := 0

# Pieces & moves
var total_pieces_captured := 0
var total_moves_made := 0

# Piece type breakdown
var pawn_captures := 0
var rook_captures := 0
var knight_captures := 0
var bishop_captures := 0
var queen_captures := 0
var king_captures := 0

# Time & sessions
var total_play_time := 0
var sessions_played := 0

# Special events
var highest_multiplier := 1


func serialize() -> Dictionary:
    return {
        # Core gameplay
        "num_games_played": num_games_played,
        "best_score": best_score,
        "total_score": total_score,
        # Pieces & moves
        "total_pieces_captured": total_pieces_captured,
        "total_moves_made": total_moves_made,
        # Piece type breakdown
        "pawn_captures": pawn_captures,
        "rook_captures": rook_captures,
        "knight_captures": knight_captures,
        "bishop_captures": bishop_captures,
        "queen_captures": queen_captures,
        "king_captures": king_captures,
        # Time & sessions
        "total_play_time": total_play_time,
        "sessions_played": sessions_played,
        # Special events
        "highest_multiplier": highest_multiplier,
    }


func deserialize(data: Dictionary) -> void:
    # Core gameplay
    num_games_played = data.get("num_games_played", 0)
    best_score = data.get("best_score", 0)
    total_score = data.get("total_score", 0)
    # Pieces & moves
    total_pieces_captured = data.get("total_pieces_captured", 0)
    total_moves_made = data.get("total_moves_made", 0)
    # Piece type breakdown
    pawn_captures = data.get("pawn_captures", 0)
    rook_captures = data.get("rook_captures", 0)
    knight_captures = data.get("knight_captures", 0)
    bishop_captures = data.get("bishop_captures", 0)
    queen_captures = data.get("queen_captures", 0)
    king_captures = data.get("king_captures", 0)
    # Time & sessions
    total_play_time = data.get("total_play_time", 0)
    sessions_played = data.get("sessions_played", 0)
    # Special events
    highest_multiplier = data.get("highest_multiplier", 1)


func end_game(single_game_stats: PlayerStats) -> void:
    """
    Merges the long-term player stats (save file) with the current game's stats.
    """
    var final_score = single_game_stats.total_score

    # Core gameplay
    num_games_played += 1
    total_score += final_score
    best_score = max(best_score, final_score)
    
    # Piece type breakdown
    pawn_captures += single_game_stats.pawn_captures
    rook_captures += single_game_stats.rook_captures
    knight_captures += single_game_stats.knight_captures
    bishop_captures += single_game_stats.bishop_captures
    queen_captures += single_game_stats.queen_captures
    king_captures += single_game_stats.king_captures

    # Special events
    highest_multiplier = max(highest_multiplier, single_game_stats.highest_multiplier)


func update_captured(piece_captured: ChessPiece) -> void:
    """
    Update the appropriate piece captures based on the piece type.
    """
    total_pieces_captured += 1

    match piece_captured.data.piece_type:
        PieceSpawnData.PieceType.PAWN:
            pawn_captures += 1
        PieceSpawnData.PieceType.ROOK:
            rook_captures += 1
        PieceSpawnData.PieceType.KNIGHT:
            knight_captures += 1
        PieceSpawnData.PieceType.BISHOP:
            bishop_captures += 1
        PieceSpawnData.PieceType.QUEEN:
            queen_captures += 1
        PieceSpawnData.PieceType.KING:
            king_captures += 1


func update_moves(new_moves: int) -> void:
    """
    Updates the total moves made.
    """
    total_moves_made = new_moves


func update_score(new_score: int) -> void:
    """
    Updates the score.
    """
    total_score = new_score


func update_multiplier(new_mult: int) -> void:
    """
    Sets highest multiplier.
    """
    highest_multiplier = max(highest_multiplier, new_mult)


func get_display_values() -> Dictionary:
    """
    Returns a dictionary where the key is the display label and the value is the display value.
    """
    # TODO: affected by localization
    return {
        "Games Played": num_games_played,
        "Best Score": best_score,
        "Total Score": total_score,
    }
