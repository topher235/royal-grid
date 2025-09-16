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


func _ready() -> void:
    _load_characters()


func _on_previous_button_pressed() -> void:
    """
    Increments the selected index and sets the selected character. Updates the visuals for the new character.
    """
    selected_character_idx = wrapi(selected_character_idx - 1, 0, characters.size())
    selected_character = characters[selected_character_idx]
    setup_visuals()
    

func _on_next_button_pressed() -> void:
    """
    Decrements the selected index and sets the selected character. Updates the visuals for the new character.
    """
    selected_character_idx = wrapi(selected_character_idx + 1, 0, characters.size())
    selected_character = characters[selected_character_idx]
    setup_visuals()
    
    
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
