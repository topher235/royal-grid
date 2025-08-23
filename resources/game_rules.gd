class_name GameRules extends Resource

@export var extra_turn_on_capture := true
@export var allow_en_passant := false
@export var allow_castling := false
@export var max_turns_without_capture := 10
@export var win_condition := WinCondition.STANDARD

enum WinCondition {
    STANDARD,
    # CAPTURE_COUNT,
    # SURVIVAL,
}
