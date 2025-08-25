@tool
class_name Tile extends Control

signal tile_clicked(tile: Tile)

enum TileState {NORMAL, HIGHLIGHTED, SELECTED, VALID_MOVE, INVALID_MOVE}

var grid_position: Vector2i = Vector2i.ZERO
var current_state: TileState = TileState.NORMAL
var is_occupied := false
var occupying_piece: ChessPiece = null
var occupying_effect: Effect = null

@export var background: ColorRect
@export var highlight: ColorRect
@export var selection: ColorRect
@export var valid_move_indicator: TextureRect
@export var pieces_container: Node
@export var effects_container: Node

var freeze_counter := 0


func _ready() -> void:
    setup_visual_nodes()
    if not Engine.is_editor_hint():
        connect_input_events()


func setup_visual_nodes() -> void:
    background.color = Color.WHITE if (grid_position.x + grid_position.y) % 2 == 0 else Color.GRAY

    highlight.color = Color.YELLOW
    highlight.modulate.a = 0.3
    highlight.visible = false

    selection.color = Color.BLUE
    selection.modulate.a = 0.5
    selection.visible = false

    valid_move_indicator.modulate.a = 0.9
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


func set_occupancy(piece: ChessPiece = null) -> void:
    is_occupied = piece != null
    occupying_piece = piece
    if piece:
        add_child(piece)
        piece.position = Vector2(0, 0)


func remove_piece(piece: ChessPiece) -> void:
    if not piece:
        return
    remove_child(piece)
    set_occupancy(null)


func add_effect(effect: Effect) -> void:
    is_occupied = not effect.can_piece_move_to()
    occupying_effect = effect
    add_child(effect)
    effect.effect_ended.connect(_on_effect_ended.bind(effect))


func remove_effect() -> Effect:
    is_occupied = false
    var effect = occupying_effect
    occupying_effect = null
    remove_child(occupying_effect)
    # have to keep this in the tree somewhere...
    get_viewport().add_child(effect)
    return effect


func _on_effect_ended(effect: Effect) -> void:
    remove_effect()


func clear_indicators() -> void:
    set_state(TileState.NORMAL)


func show_valid_move() -> void:
    set_state(TileState.VALID_MOVE)


func select() -> void:
    set_state(TileState.SELECTED)


func deselect() -> void:
    set_state(TileState.NORMAL)


func freeze(duration: int) -> void:
    freeze_counter += duration


func on_end_turn() -> void:
    """
    Various cleanup tasks after a player makes their move.
    """
    if freeze_counter > 0:
        freeze_counter -= 1
