class_name PieceSpawnData extends Resource

enum PieceType {PAWN, ROOK, KNIGHT, BISHOP, QUEEN, KING}

@export var piece_type: PieceType:
    set = _set_piece_type
@export var position: Vector2i
@export var color: bool = true  # true = white, false = black
@export var has_moved: bool = false
@export var rules: PieceRules


func _init() -> void:
    piece_type = PieceType.PAWN
    position = Vector2i.ZERO
    color = true
    has_moved = false
    _init_rules()


func _set_piece_type(value: PieceType) -> void:
    piece_type = value
    _init_rules()


func get_piece_type() -> String:
    return rules.get_piece_type()


func _init_rules() -> void:
    match piece_type:
        PieceType.PAWN:
            rules = PawnRules.new()
        PieceType.ROOK:
            rules = RookRules.new()
        PieceType.KNIGHT:
            rules = KnightRules.new()
        PieceType.BISHOP:
            rules = BishopRules.new()
        PieceType.QUEEN:
            rules = QueenRules.new()
        PieceType.KING:
            rules = KingRules.new()
