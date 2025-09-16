class_name CharacterSelector extends Control

@export var previous_button: TextureButton
@export var next_button: TextureButton
@export var avatar_preview: TextureRect
@export var name_label: Label
@export var description_label: Label

var characters: Array[BaseCharacter]
var selected_character_idx := 0
var selected_character: BaseCharacter
var characters_directory := "res://resources/characters/"
var is_animating := false


func _ready() -> void:
    _load_characters()


func _on_previous_button_pressed() -> void:
    """
    Increments the selected index and sets the selected character. Updates the visuals for the new character.
    """
    if is_animating or characters.is_empty():
        return
    play_carousel(-1.0)
    

func _on_next_button_pressed() -> void:
    """
    Decrements the selected index and sets the selected character. Updates the visuals for the new character.
    """
    if is_animating or characters.is_empty():
        return
    play_carousel(1.0)
    
    
func _custom_character_sort(a: BaseCharacter, b: BaseCharacter) -> bool:
    if a.priority != b.priority:
        return a.priority > b.priority
    return a.name < b.name
    

func _load_characters() -> void:
    characters.clear()
    
    var dir := DirAccess.open(characters_directory)
    if dir:
        dir.list_dir_begin()
        var file_name := dir.get_next()
        
        while file_name != "":
            if file_name.ends_with(".tres") and not file_name.begins_with("base"):
                var full_path := characters_directory + file_name
                var character := load(full_path) as BaseCharacter
                characters.append(character)
            file_name = dir.get_next()
        
    if characters.size() > 0:
        characters.sort_custom(_custom_character_sort)
        selected_character = characters[selected_character_idx]
        setup_visuals()

        
func setup_visuals() -> void:
    """
    Sets up the visuals for the character avatar, name, and effect description.
    """
    avatar_preview.texture = selected_character.avatar
    name_label.text = selected_character.name
    description_label.text = selected_character.effect_description

    
func play_carousel(direction: float) -> void:
    """
    direction: 1 for next (slide left), -1 for previous (slide right)
    """
    is_animating = true
    previous_button.disabled = true
    next_button.disabled = true
    
    var base_x := avatar_preview.position.x
    var distance := 64.0
    var dur_out := 0.18
    var dur_in := 0.22
    var new_idx := wrapi(selected_character_idx + direction, 0, characters.size())
    
    var tween := create_tween()
    tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
    
    # Slide current out and fade labels out
    var directional_distance := direction * distance
    tween.tween_property(avatar_preview, "position:x", base_x - directional_distance, dur_out)
    tween.parallel().tween_property(avatar_preview, "modulate:a", 0.0, dur_out * 0.75)
    tween.parallel().tween_property(name_label, "modulate:a", 0.0, dur_out * 0.9)
    tween.parallel().tween_property(description_label, "modulate:a", 0.0, dur_out * 0.9)
    
    # Swap content and prep incoming position
    tween.tween_callback(_carousel_swap_and_prep.bind(new_idx, direction, base_x, distance))
    
    # Slide new in and fade labels in
    tween.tween_property(avatar_preview, "position:x", base_x, dur_in)
    tween.parallel().tween_property(avatar_preview, "modulate:a", 1.0, dur_in)
    tween.parallel().tween_property(name_label, "modulate:a", 1.0, dur_in)
    tween.parallel().tween_property(description_label, "modulate:a", 1.0, dur_in)
    
    tween.tween_callback(_carousel_finish)

    
func _carousel_swap_and_prep(new_idx: int, direction: float, base_x: float, distance: float) -> void:
    selected_character_idx = new_idx
    selected_character = characters[selected_character_idx]
    setup_visuals()
    
    # Start just off-screen on the incoming side
    var directional_distance := direction * distance
    avatar_preview.position.x = base_x + directional_distance
    # Ensure labels are ready to fade back in
    name_label.modulate.a = 0.0
    description_label.modulate.a = 0.0
    
    
func _carousel_finish() -> void:
    is_animating = false
    previous_button.disabled = false
    next_button.disabled = false
