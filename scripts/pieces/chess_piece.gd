class_name ChessPiece extends Control

signal piece_clicked(piece: ChessPiece)

var piece_color := true  # true = white, false = black
var grid_position: Vector2i = Vector2i.ZERO
var has_moved := false


func _ready() -> void:
    mouse_entered.connect(_on_mouse_entered)
    mouse_exited.connect(_on_mouse_exited)


func _on_mouse_entered() -> void:
    modulate = Color.YELLOW


func _on_mouse_exited() -> void:
    modulate = Color.WHITE


func _gui_input(event: InputEvent) -> void:
    if event is InputEventMouseButton and event.is_pressed():
        piece_clicked.emit(self)


func set_grid_position(pos: Vector2i) -> void:
    grid_position = pos


func get_legal_moves() -> Array[Vector2i]:
    # to be overridden by specific piece types
    return []


func can_move_to(pos: Vector2i) -> bool:
    var legal_moves = get_legal_moves()
    return pos in legal_moves


func move_to(new_pos: Vector2i) -> void:
    grid_position = new_pos
    has_moved = true
