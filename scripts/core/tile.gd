@tool
class_name Tile extends Control

signal tile_clicked(tile: Tile)

enum TileState {NORMAL, HIGHLIGHTED, SELECTED, VALID_MOVE, INVALID_MOVE}

var grid_position: Vector2i = Vector2i.ZERO
var current_state: TileState = TileState.NORMAL
var is_occupied := false
var occupying_piece: Node2D = null

@export var background: ColorRect
@export var highlight: ColorRect
@export var selection: ColorRect
@export var valid_move_indicator: ColorRect


func _ready() -> void:
    setup_visual_nodes()
    connect_input_events()


func setup_visual_nodes() -> void:
    background.color = Color.WHITE if (grid_position.x + grid_position.y) % 2 == 0 else Color.GRAY

    highlight.color = Color.YELLOW
    highlight.modulate.a = 0.3
    highlight.visible = false

    selection.color = Color.BLUE
    selection.modulate.a = 0.5
    selection.visible = false

    valid_move_indicator.color = Color.GREEN
    valid_move_indicator.modulate.a = 0.6
    valid_move_indicator.visible = false


func connect_input_events() -> void:
    mouse_entered.connect(_on_mouse_entered)
    mouse_exited.connect(_on_mouse_exited)


func _on_mouse_entered() -> void:
    if current_state != TileState.SELECTED:
        set_state(TileState.HIGHLIGHTED)


func _on_mouse_exited() -> void:
    if current_state == TileState.HIGHLIGHTED:
        set_state(TileState.NORMAL)
    

func _on_gui_input(event: InputEvent) -> void:
    if event is InputEventMouseButton and event.is_pressed():
        tile_clicked.emit(self)


func set_state(new_state: TileState) -> void:
    current_state = new_state

    highlight.visible = false
    selection.visible = false
    valid_move_indicator.visible = false

    match new_state:
        TileState.NORMAL:
            pass
        TileState.HIGHLIGHTED:
            highlight.visible = true
        TileState.SELECTED:
            selection.visible = true
        TileState.VALID_MOVE:
            valid_move_indicator.visible = true


func set_occupancy(piece: Node2D = null) -> void:
    is_occupied = piece != null
    occupying_piece = piece


func clear_indicators() -> void:
    set_state(TileState.NORMAL)


func show_valid_move() -> void:
    set_state(TileState.VALID_MOVE)


func select() -> void:
    set_state(TileState.SELECTED)


func deselect() -> void:
    set_state(TileState.NORMAL)
