class_name PieceSpawnData extends Resource

enum PieceType {PAWN, ROOK, KNIGHT, BISHOP, QUEEN, KING}

const PAWN_RULES = preload("res://resources/pieces/pawn_rules.gd")
const ROOK_RULES = preload("res://resources/pieces/rook_rules.gd")
const KNIGHT_RULES = preload("res://resources/pieces/knight_rules.gd")
const BISHOP_RULES = preload("res://resources/pieces/bishop_rules.gd")
const QUEEN_RULES = preload("res://resources/pieces/queen_rules.gd")
const KING_RULES = preload("res://resources/pieces/king_rules.gd")

@export var piece_type: PieceType:
    set = _set_piece_type
@export var position: Vector2i
@export var color: bool = true  # true = white, false = black
@export var has_moved: bool = false
@export var rules: PieceRules

var points: int:
    get = _get_points


func _init() -> void:
    piece_type = PieceType.PAWN
    position = Vector2i.ZERO
    color = true
    has_moved = false
    # _init_rules()


func _set_piece_type(value: PieceType) -> void:
    piece_type = value
    _init_rules()


func get_piece_type() -> String:
    if not rules:
        return ""
    
    return rules.get_piece_type()


func _init_rules() -> void:
    match piece_type:
        PieceType.PAWN:
            rules = PAWN_RULES.new()
        PieceType.ROOK:
            rules = ROOK_RULES.new()
        PieceType.KNIGHT:
            rules = KNIGHT_RULES.new()
        PieceType.BISHOP:
            rules = BISHOP_RULES.new()
        PieceType.QUEEN:
            rules = QUEEN_RULES.new()
        PieceType.KING:
            rules = KING_RULES.new()


func _get_points() -> int:
    match piece_type:
        PieceType.PAWN:
            return 10
        PieceType.ROOK:
            return 5
        PieceType.KNIGHT:
            return 8
        PieceType.BISHOP:
            return 5
        PieceType.QUEEN:
            return 2
        PieceType.KING:
            return 10
    return 0
