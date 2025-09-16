class_name MapSelector extends Control

@export var previous_button: TextureButton
@export var next_button: TextureButton
@export var preview_texture_rect: TextureRect
@export var name_label: Label

var maps: Array[Map]
var selected_map_idx := 0
var selected_map: Map
var maps_directory := "res://resources/maps/"


func _ready() -> void:
    _load_maps()


func _on_previous_button_pressed() -> void:
    """
    Increments the selected index and sets the selected map. Updates the visuals for the new map.
    """
    selected_map_idx = wrapi(selected_map_idx - 1, 0, maps.size())
    selected_map = maps[selected_map_idx]
    setup_visuals()


func _on_next_button_pressed() -> void:
    """
    Decrements the selected index and sets the selected map. Updates the visuals for the new map.
    """
    selected_map_idx = wrapi(selected_map_idx + 1, 0, maps.size())
    selected_map = maps[selected_map_idx]
    setup_visuals()

    
func _custom_map_sort(a: Map, b: Map) -> bool:
    if a.priority != b.priority:
        return a.priority > b.priority  # Higher priority first
    return a.map_name < b.map_name
    

func _load_maps() -> void:
    maps.clear()

    var dir := DirAccess.open(maps_directory)
    if dir:
        dir.list_dir_begin()
        var file_name := dir.get_next()

        while file_name != "":
            if file_name.ends_with(".tres"):
                var full_path := maps_directory + file_name
                var map := load(full_path) as Map
                maps.append(map)
            file_name = dir.get_next()

    if maps.size() > 0:
        maps.sort_custom(_custom_map_sort)
        selected_map = maps[selected_map_idx]
        setup_visuals()


func setup_visuals() -> void:
    """
    Sets up the visuals for the character preview and name.
    """
    preview_texture_rect.texture = selected_map.preview
    name_label.text = selected_map.map_name
