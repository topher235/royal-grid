class_name CosmeticSelector extends Control

@export var previous_button: TextureButton
@export var next_button: TextureButton
@export var avatar_preview: TextureRect
@export var name_label: Label

var cosmetics: Array[BaseCosmetic]
var selected_cosmetic_idx := 0
var selected_cosmetic: BaseCosmetic
var cosmetics_directory := "res://resources/cosmetics/"


func _ready() -> void:
    _load_cosmetics()


func _on_previous_button_pressed() -> void:
    """
    Increments the selected index and sets the selected cosmetic. Updates the visuals for the new cosmetic.
    """
    selected_cosmetic_idx = wrapi(selected_cosmetic_idx - 1, 0, cosmetics.size())
    selected_cosmetic = cosmetics[selected_cosmetic_idx]
    setup_visuals()


func _on_next_button_pressed() -> void:
    """
    Decrements the selected index and sets the selected cosmetic. Updates the visuals for the new cosmetic.
    """
    selected_cosmetic_idx = wrapi(selected_cosmetic_idx + 1, 0, cosmetics.size())
    selected_cosmetic = cosmetics[selected_cosmetic_idx]
    setup_visuals()
    
    
func _custom_cosmetic_sort(a: BaseCosmetic, b: BaseCosmetic) -> bool:
    if a.priority != b.priority:
        return a.priority > b.priority
    return a.chess_set_name < b.chess_set_name


func _load_cosmetics() -> void:
    cosmetics.clear()

    var dir := DirAccess.open(cosmetics_directory)
    if dir:
        dir.list_dir_begin()
        var file_name := dir.get_next()

        while file_name != "":
            if file_name.ends_with(".tres") and not file_name.begins_with("base"):
                var full_path := cosmetics_directory + file_name
                var cosmetic := load(full_path) as BaseCosmetic
                cosmetics.append(cosmetic)
            file_name = dir.get_next()

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
