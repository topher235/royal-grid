class_name MapListItem extends HBoxContainer

signal map_selected(map_item: MapListItem)

@export var map_name_label: Label
@export var map_id_label: Label
@export var select_button: Button

var map_path: String = ""
var map: Map


func _ready() -> void:
    setup_ui()
    connect_signals()


func setup_ui() -> void:
    """Setup the UI elements"""
    if not map_name_label:
        map_name_label = Label.new()
        map_name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        add_child(map_name_label)
    
    if not map_id_label:
        map_id_label = Label.new()
        map_id_label.custom_minimum_size = Vector2(50, 0)
        add_child(map_id_label)
    
    if not select_button:
        select_button = Button.new()
        select_button.text = "Select"
        add_child(select_button)


func connect_signals() -> void:
    """Connect signals"""
    if select_button:
        select_button.pressed.connect(_on_select_button_pressed)


func load_map_info() -> void:
    """Load map information from file"""
    if map_path.is_empty():
        return
    
    map = load(map_path) as Map
    if map:
        if map_name_label:
            map_name_label.text = map.map_name
        if map_id_label:
            map_id_label.text = str(map.map_id)


func _on_select_button_pressed() -> void:
    """Handle select button press"""
    map_selected.emit(self)
