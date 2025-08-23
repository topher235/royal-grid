class_name ChessPiece extends Control

@export var label: Label

var color: bool:
    get = _get_color
var grid_position: Vector2i = Vector2i.ZERO:
    get = _get_grid_position
var data: PieceSpawnData:
    set = _set_data


func _set_data(value: PieceSpawnData) -> void:
    data = value
    grid_position = data.position
    var color = "W" if data.color else "B"
    label.text = color + " - " + data.get_piece_type()


func _get_color() -> bool:
    return data.color


func set_grid_position(pos: Vector2i) -> void:
    data.position = pos


func _get_grid_position() -> Vector2i:
    return data.position


func get_legal_moves() -> Array[Vector2i]:
    var board = get_tree().get_first_node_in_group("gameboard")
    return data.rules.get_legal_moves(board, data)
