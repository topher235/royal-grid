class_name MapSelector extends Control

@export var previous_button: TextureButton
@export var next_button: TextureButton
@export var preview_texture_rect: TextureRect
@export var name_label: Label

var maps: Array[Map]
var selected_map_idx := 0
var selected_map: Map
var maps_directory := "res://resources/maps/"
var is_animating := false


func _ready() -> void:
    _load_maps()


func _on_previous_button_pressed() -> void:
    """
    Increments the selected index and sets the selected map. Updates the visuals for the new map.
    """
    if is_animating or maps.is_empty():
        return
    play_carousel(-1.0)


func _on_next_button_pressed() -> void:
    """
    Decrements the selected index and sets the selected map. Updates the visuals for the new map.
    """
    if is_animating or maps.is_empty():
        return
    play_carousel(1.0)

    
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


func play_carousel(direction: float) -> void:
    """
    direction: 1 for next (slide left), -1 for previous (slide right)
    """
    is_animating = true
    previous_button.disabled = true
    next_button.disabled = true

    var base_x := preview_texture_rect.position.x
    var distance := 32.0
    var dur_out := 0.18
    var dur_in := 0.22
    var new_idx := wrapi(selected_map_idx + direction, 0, maps.size())

    var tween := create_tween()
    tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)

    # Slide current out and fade labels out
    var directional_distance := direction * distance
    tween.tween_property(preview_texture_rect, "position:x", base_x - directional_distance, dur_out)
    tween.parallel().tween_property(preview_texture_rect, "modulate:a", 0.0, dur_out * 0.9)
    tween.parallel().tween_property(name_label, "modulate:a", 0.0, dur_out * 0.9)

    # Swap content and prep incoming position
    tween.tween_callback(_carousel_swap_and_prep.bind(new_idx, direction, base_x, distance))

    # Slide new in and fade labels in
    tween.tween_property(preview_texture_rect, "position:x", base_x, dur_in)
    tween.parallel().tween_property(preview_texture_rect, "modulate:a", 1.0, dur_in)
    tween.parallel().tween_property(name_label, "modulate:a", 1.0, dur_in)

    tween.tween_callback(_carousel_finish)


func _carousel_swap_and_prep(new_idx: int, direction: float, base_x: float, distance: float) -> void:
    selected_map_idx = new_idx
    selected_map = maps[selected_map_idx]
    setup_visuals()

    # Start just off-screen on the incoming side
    var directional_distance := direction * distance
    preview_texture_rect.position.x = base_x + directional_distance
    # Ensure labels are ready to fade back in
    name_label.modulate.a = 0.0


func _carousel_finish() -> void:
    is_animating = false
    previous_button.disabled = false
    next_button.disabled = false
