extends Node

const PAWN_WHITE = preload("res://assets/images/cartoon/chess-pawn-white.png")
const KNIGHT_WHITE = preload("res://assets/images/cartoon/chess-knight-white.png")
const ROOK_WHITE = preload("res://assets/images/cartoon/chess-rook-white.png")
const BISHOP_WHITE = preload("res://assets/images/cartoon/chess-bishop-white.png")
const QUEEN_WHITE = preload("res://assets/images/cartoon/chess-queen-white.png")
const KING_WHITE = preload("res://assets/images/cartoon/chess-king-white.png")

const PAWN_BLACK = preload("res://assets/images/cartoon/chess-pawn-black.png")
const KNIGHT_BLACK = preload("res://assets/images/cartoon/chess-knight-black.png")
const ROOK_BLACK = preload("res://assets/images/cartoon/chess-rook-black.png")
const BISHOP_BLACK = preload("res://assets/images/cartoon/chess-bishop-black.png")
const QUEEN_BLACK = preload("res://assets/images/cartoon/chess-queen-black.png")
const KING_BLACK = preload("res://assets/images/cartoon/chess-king-black.png")

const BLOCK_ICON = preload("res://assets/images/effects/block.png")
const BOMB_ICON = preload("res://assets/images/effects/bomb.png")
const FREEZE_ICON = preload("res://assets/images/effects/freeze.png")
const MULT_ICON = preload("res://assets/images/effects/multiplier.png")
const SPAWN_ICON = preload("res://assets/images/effects/spawn.png")
const ROTATE_CLOCKWISE_ICON = preload("res://assets/images/effects/rotate_clockwise.png")

const WHITE_SPRITES = {
    PieceSpawnData.PieceType.PAWN: PAWN_WHITE,
    PieceSpawnData.PieceType.KNIGHT: KNIGHT_WHITE,
    PieceSpawnData.PieceType.ROOK: ROOK_WHITE,
    PieceSpawnData.PieceType.BISHOP: BISHOP_WHITE,
    PieceSpawnData.PieceType.QUEEN: QUEEN_WHITE,
    PieceSpawnData.PieceType.KING: KING_WHITE,
}

const BLACK_SPRITES = {
    PieceSpawnData.PieceType.PAWN: PAWN_BLACK,
    PieceSpawnData.PieceType.KNIGHT: KNIGHT_BLACK,
    PieceSpawnData.PieceType.ROOK: ROOK_BLACK,
    PieceSpawnData.PieceType.BISHOP: BISHOP_BLACK,
    PieceSpawnData.PieceType.QUEEN: QUEEN_BLACK,
    PieceSpawnData.PieceType.KING: KING_BLACK,
}


func get_sprite_texture(piece_type: PieceSpawnData.PieceType, color: bool) -> Texture:
    # true = white, false = black
    if color:
        return WHITE_SPRITES[piece_type]
    return BLACK_SPRITES[piece_type]
