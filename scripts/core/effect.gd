@tool
class_name Effect extends Node2D

signal effect_ended

@export var background: ColorRect
@export var label: Label
@export var color: Color = Color.BLUE
@export var special_effect: SpecialEffect:
    set = _set_special_effect
@export var data: EffectSpawnData:
    set = _set_data

var grid_position: Vector2i = Vector2i.ZERO:
    get = _get_grid_position


func _ready() -> void:
    background.color = color
    if data:
        special_effect = data.effect
    
    if special_effect:
        special_effect.end_effect.connect(_on_effect_end)
        label.text = special_effect.name


func on_end_turn() -> void:
    var board: ChessBoard = get_tree().get_first_node_in_group("gameboard")
    special_effect.decrement_duration(board.game_manager)


func _on_effect_end() -> void:
    effect_ended.emit()
    queue_free()


func _set_data(value: EffectSpawnData) -> void:
    data = value
    special_effect = data.effect


func _set_special_effect(value: SpecialEffect) -> void:
    special_effect = value
    label.text = special_effect.name


func can_piece_move_to() -> bool:
    return special_effect.can_piece_move_to


func _get_grid_position() -> Vector2i:
    return data.position


func execute() -> void:
    var board: ChessBoard = get_tree().get_first_node_in_group("gameboard")
    special_effect.execute(board.game_manager, grid_position)
    queue_free()
