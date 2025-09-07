class_name TilePreview extends Control

signal tile_clicked(tile: TilePreview)
signal tile_hovered(tile: TilePreview)
signal tile_unhovered(tile: TilePreview)

@export var background: ColorRect
@export var hover_outline: ColorRect
@export var active_indicator: ColorRect

var grid_position: Vector2i = Vector2i.ZERO
var is_active: bool = true


func _ready() -> void:
    setup_visual_nodes()
    connect_input_events()


func setup_visual_nodes() -> void:
    """Setup the visual appearance of the tile"""
    if background:
        background.color = Color(0.8, 0.8, 0.8, 1) if is_active else Color(0.3, 0.3, 0.3, 1)
    
    if active_indicator:
        active_indicator.visible = is_active


func connect_input_events() -> void:
    """Connect input events"""
    mouse_entered.connect(_on_mouse_entered)
    mouse_exited.connect(_on_mouse_exited)


func _on_mouse_entered() -> void:
    """Handle mouse enter"""
    tile_hovered.emit(self)
    show_hover()


func _on_mouse_exited() -> void:
    """Handle mouse exit"""
    tile_unhovered.emit(self)
    hide_hover()


func _on_gui_input(event: InputEvent) -> void:
    """Handle GUI input"""
    if event is InputEventMouseButton and event.is_pressed():
        tile_clicked.emit(self)


func set_active(active: bool) -> void:
    """Set the active state of the tile"""
    is_active = active
    setup_visual_nodes()


func show_hover() -> void:
    """Show hover outline"""
    if hover_outline:
        hover_outline.visible = true


func hide_hover() -> void:
    """Hide hover outline"""
    if hover_outline:
        hover_outline.visible = false
