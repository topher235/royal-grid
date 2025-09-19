class_name CosmeticSelector extends Control

@export var previous_button: TextureButton
@export var next_button: TextureButton
@export var avatar_preview: TextureRect
@export var name_label: Label

var cosmetics: Array[BaseCosmetic]
var selected_cosmetic_idx := 0
var selected_cosmetic: BaseCosmetic
var cosmetics_directory := "res://resources/cosmetics/"
var is_animating := false


func _ready() -> void:
    _load_cosmetics()


func _on_previous_button_pressed() -> void:
    """
    Increments the selected index and sets the selected cosmetic. Updates the visuals for the new cosmetic.
    """
    if is_animating or cosmetics.is_empty():
        return
    play_carousel(-1.0)


func _on_next_button_pressed() -> void:
    """
    Decrements the selected index and sets the selected cosmetic. Updates the visuals for the new cosmetic.
    """
    if is_animating or cosmetics.is_empty():
        return
    play_carousel(1.0)
    
    
func _custom_cosmetic_sort(a: BaseCosmetic, b: BaseCosmetic) -> bool:
    if a.priority != b.priority:
        return a.priority > b.priority
    return a.chess_set_name < b.chess_set_name


func _load_cosmetics() -> void:
    cosmetics.clear()

    for path in CosmeticsDatabase.PATHS:
        Log.info(self, path)
        var cosmetic := load(path) as BaseCosmetic
        cosmetics.append(cosmetic)

    if cosmetics.size() > 0:
        cosmetics.sort_custom(_custom_cosmetic_sort)
        selected_cosmetic = cosmetics[selected_cosmetic_idx]
        setup_visuals()


func setup_visuals() -> void:
    """
    Sets up the visuals for the character avatar and name.
    """
    avatar_preview.texture = selected_cosmetic.avatar
    name_label.text = selected_cosmetic.chess_set_name


func play_carousel(direction: float) -> void:
    """
    direction: 1 for next (slide left), -1 for previous (slide right)
    """
    is_animating = true
    previous_button.disabled = true
    next_button.disabled = true

    var base_x := avatar_preview.position.x
    var distance := 32.0
    var dur_out := 0.25
    var dur_in := 0.3
    var new_idx := wrapi(selected_cosmetic_idx + direction, 0, cosmetics.size())

    var tween := create_tween()
    tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)

    # Slide current out and fade labels out
    var directional_distance := direction * distance
    tween.tween_property(avatar_preview, "position:x", base_x - directional_distance, dur_out)
    tween.parallel().tween_property(avatar_preview, "modulate:a", 0.0, dur_out * 0.9)
    tween.parallel().tween_property(name_label, "modulate:a", 0.0, dur_out * 0.9)

    # Swap content and prep incoming position
    tween.tween_callback(_carousel_swap_and_prep.bind(new_idx, direction, base_x, distance))

    # Slide new in and fade labels in
    tween.tween_property(avatar_preview, "position:x", base_x, dur_in)
    tween.parallel().tween_property(avatar_preview, "modulate:a", 1.0, dur_in)
    tween.parallel().tween_property(name_label, "modulate:a", 1.0, dur_in)

    tween.tween_callback(_carousel_finish)


func _carousel_swap_and_prep(new_idx: int, direction: float, base_x: float, distance: float) -> void:
    selected_cosmetic_idx = new_idx
    selected_cosmetic = cosmetics[selected_cosmetic_idx]
    setup_visuals()

    # Start just off-screen on the incoming side
    var directional_distance := direction * distance
    avatar_preview.position.x = base_x + directional_distance
    # Ensure labels are ready to fade back in
    name_label.modulate.a = 0.0


func _carousel_finish() -> void:
    is_animating = false
    previous_button.disabled = false
    next_button.disabled = false
