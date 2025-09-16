extends Control

signal scene_changed(to_path: String)

@export var back_button: TextureButton
@export var character_selector: CharacterSelector
@export var map_selector: MapSelector
@export var cosmetic_selector: CosmeticSelector
@export var rush_button: TextureButton
@export var classic_button: TextureButton

var active_game_config: GameConfig


func _ready() -> void:
    pass
    
    
func _on_back_button_texture_pressed() -> void:
    scene_changed.emit("res://scenes/ui/main_menu.tscn")

    
func _on_play_rush_button_pressed() -> void:
    var spawn_rules := PieceSpawnRules.new()
    spawn_rules.spawn_on_timer = true
    create_game_config(spawn_rules)
    if active_game_config:
        scene_changed.emit("res://scenes/ui/game_ui.tscn")

    
func _on_play_classic_button_pressed() -> void:
    var spawn_rules := PieceSpawnRules.new()
    spawn_rules.spawn_on_timer = false
    create_game_config(spawn_rules)
    if active_game_config:
        scene_changed.emit("res://scenes/ui/game_ui.tscn")
    

func create_game_config(spawn_rules: PieceSpawnRules) -> void:
    var gc = GameConfig.new()

    gc.map = map_selector.selected_map
    gc.cosmetic = cosmetic_selector.selected_cosmetic
    gc.piece_spawn_rules = spawn_rules
    gc.character = character_selector.selected_character
    
    active_game_config = gc
    

func get_scene_data() -> Dictionary:
    return {
        "game_config": active_game_config,
        "continue": false,
    }
    
    
func set_scene_data(value: Dictionary) -> void:
    pass
    
