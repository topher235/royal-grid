class_name MapEditor extends Control

signal map_editor_closed

@export var map_preview: Control
@export var map_id_spin_box: SpinBox
@export var map_name_line_edit: LineEdit
@export var grid_size_x_spin_box: SpinBox
@export var grid_size_y_spin_box: SpinBox
@export var background_sprite_button: Button
@export var load_map_button: Button
@export var save_map_button: Button
@export var new_map_button: Button
@export var close_button: Button
@export var map_load_modal: AcceptDialog
@export var map_list_vbox: VBoxContainer

const TILE_PREVIEW_SCENE = preload("res://scenes/map_editor/tile_preview.tscn")

var current_map: Map
var tile_previews: Array[Array] = []
var selected_background: Texture2D
var maps_directory: String = "res://resources/maps/"
var selected_map_item: MapListItem = null


func _ready() -> void:
    setup_connections()
    create_new_map()
    update_preview()


func setup_connections() -> void:
    # Map info changes
    map_id_spin_box.value_changed.connect(_on_map_id_changed)
    map_name_line_edit.text_changed.connect(_on_map_name_changed)
    grid_size_x_spin_box.value_changed.connect(_on_grid_size_changed)
    grid_size_y_spin_box.value_changed.connect(_on_grid_size_changed)
    
    # Buttons
    background_sprite_button.pressed.connect(_on_background_sprite_button_pressed)
    load_map_button.pressed.connect(_on_load_map_button_pressed)
    save_map_button.pressed.connect(_on_save_map_button_pressed)
    new_map_button.pressed.connect(_on_new_map_button_pressed)
    close_button.pressed.connect(_on_close_button_pressed)
    
    # Modal
    map_load_modal.confirmed.connect(_on_map_load_confirmed)


func create_new_map() -> void:
    """Create a new empty map"""
    current_map = Map.new()
    current_map.map_id = int(map_id_spin_box.value)
    current_map.map_name = map_name_line_edit.text
    current_map.grid_size = Vector2i(int(grid_size_x_spin_box.value), int(grid_size_y_spin_box.value))
    current_map.background_sprite = selected_background
    current_map.initialize_tile_data()
    update_preview()


func load_map(map_path: String) -> void:
    """Load a map from file"""
    var map = load(map_path) as Map
    if map:
        current_map = map
        update_ui_from_map()
        update_preview()
        Log.info(self, "Loaded map: " + map.map_name)
    else:
        Log.error(self, "Failed to load map from: " + map_path)


func save_map() -> void:
    """Save the current map to file"""
    if not current_map:
        Log.error(self, "No map to save")
        return
    
    # Update map data from UI
    current_map.map_id = int(map_id_spin_box.value)
    current_map.map_name = map_name_line_edit.text
    current_map.grid_size = Vector2i(int(grid_size_x_spin_box.value), int(grid_size_y_spin_box.value))
    current_map.background_sprite = selected_background
    
    # Create maps directory if it doesn't exist
    if not DirAccess.dir_exists_absolute(maps_directory):
        DirAccess.make_dir_recursive_absolute(maps_directory)
    
    # Save the map
    var file_path = maps_directory + "map_" + str(current_map.map_id) + ".tres"
    var result = ResourceSaver.save(current_map, file_path)
    
    if result == OK:
        Log.info(self, "Map saved to: " + file_path)
    else:
        Log.error(self, "Failed to save map to: " + file_path)


func update_ui_from_map() -> void:
    """Update UI elements from current map"""
    if not current_map:
        return
    
    map_id_spin_box.value = current_map.map_id
    map_name_line_edit.text = current_map.map_name
    grid_size_x_spin_box.value = current_map.grid_size.x
    grid_size_y_spin_box.value = current_map.grid_size.y
    
    if current_map.background_sprite:
        selected_background = current_map.background_sprite
        background_sprite_button.text = "Change Background"
    else:
        background_sprite_button.text = "Select Background"


func update_preview() -> void:
    """Update the map preview"""
    if not current_map:
        return
    
    # Clear existing preview
    clear_preview()
    
    # Create new preview tiles
    var tile_size = 40
    var grid_size = current_map.grid_size
    
    tile_previews.clear()
    tile_previews.resize(grid_size.x)
    
    for x in range(grid_size.x):
        tile_previews[x] = []
        tile_previews[x].resize(grid_size.y)
        
        for y in range(grid_size.y):
            var tile_preview = TILE_PREVIEW_SCENE.instantiate() as TilePreview
            if tile_preview:
                tile_preview.grid_position = Vector2i(x, y)
                tile_preview.position = Vector2(x * tile_size, y * tile_size)
                tile_preview.custom_minimum_size = Vector2(tile_size, tile_size)
                tile_preview.tile_clicked.connect(_on_tile_preview_clicked)
                tile_preview.tile_hovered.connect(_on_tile_preview_hovered)
                tile_preview.tile_unhovered.connect(_on_tile_preview_unhovered)
                
                # Set tile state
                var tile_data = current_map.get_tile_data(Vector2i(x, y))
                if tile_data:
                    tile_preview.set_active(tile_data.is_active)
                
                tile_previews[x][y] = tile_preview
                map_preview.add_child(tile_preview)


func clear_preview() -> void:
    """Clear all preview tiles"""
    for x in range(tile_previews.size()):
        for y in range(tile_previews[x].size()):
            var tile = tile_previews[x][y]
            if tile:
                tile.queue_free()
    tile_previews.clear()


func load_available_maps() -> Array[String]:
    """Load all available map files"""
    var maps: Array[String] = []
    var dir = DirAccess.open(maps_directory)
    
    if dir:
        dir.list_dir_begin()
        var file_name = dir.get_next()
        
        while file_name != "":
            if file_name.ends_with(".tres"):
                maps.append(maps_directory + file_name)
            file_name = dir.get_next()
    
    return maps


func show_map_load_modal() -> void:
    """Show the map load modal with available maps"""
    # Clear existing map list
    for child in map_list_vbox.get_children():
        child.queue_free()
    
    # Load available maps
    var maps = load_available_maps()
    
    if maps.is_empty():
        var no_maps_label = Label.new()
        no_maps_label.text = "No maps found"
        map_list_vbox.add_child(no_maps_label)
    else:
        for map_path in maps:
            var map_item = MapListItem.new()
            map_item.map_path = map_path
            map_item.map_selected.connect(_on_map_item_selected)
            map_list_vbox.add_child(map_item)
    
    map_load_modal.popup_centered()


# Signal handlers
func _on_map_id_changed(value: float) -> void:
    if current_map:
        current_map.map_id = int(value)


func _on_map_name_changed(new_text: String) -> void:
    if current_map:
        current_map.map_name = new_text


func _on_grid_size_changed(value: float) -> void:
    if current_map:
        var new_size = Vector2i(int(grid_size_x_spin_box.value), int(grid_size_y_spin_box.value))
        current_map.resize_grid(new_size)
        update_preview()


func _on_background_sprite_button_pressed() -> void:
    # TODO: Implement file dialog for background selection
    Log.info(self, "Background sprite selection not implemented yet")


func _on_load_map_button_pressed() -> void:
    show_map_load_modal()


func _on_save_map_button_pressed() -> void:
    save_map()


func _on_new_map_button_pressed() -> void:
    create_new_map()


func _on_close_button_pressed() -> void:
    map_editor_closed.emit()
    queue_free()


func _on_tile_preview_clicked(tile: TilePreview) -> void:
    """Handle tile preview click - toggle active state"""
    if current_map:
        current_map.toggle_tile(tile.grid_position)
        tile.set_active(current_map.is_tile_active(tile.grid_position))


func _on_tile_preview_hovered(tile: TilePreview) -> void:
    """Handle tile preview hover - show white outline"""
    tile.show_hover()


func _on_tile_preview_unhovered(tile: TilePreview) -> void:
    """Handle tile preview unhover - hide white outline"""
    tile.hide_hover()


func _on_map_item_selected(map_item: MapListItem) -> void:
    """Handle map item selection"""
    selected_map_item = map_item


func _on_map_load_confirmed() -> void:
    """Handle map load confirmation"""
    if selected_map_item:
        load_map(selected_map_item.map_path)
        selected_map_item = null
