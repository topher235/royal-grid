class_name ChessPiece extends Control

@export var label: Label
@export var sprite: TextureRect
@export var sprite_atlas: ChessSpriteAtlas
@export var data: PieceSpawnData:
    set = _set_data

var color: bool:
    get = _get_color
var grid_position: Vector2i = Vector2i.ZERO:
    get = _get_grid_position


func _ready() -> void:
    update_visuals()


func _set_data(value: PieceSpawnData) -> void:
    data = value
    grid_position = data.position
    update_visuals()


func _get_color() -> bool:
    return data.color


func set_grid_position(pos: Vector2i) -> void:
    data.position = pos


func _get_grid_position() -> Vector2i:
    return data.position


func get_legal_moves() -> Array[Vector2i]:
    var board = get_tree().get_first_node_in_group("gameboard")
    return data.rules.get_legal_moves(board, data)


func update_visuals() -> void:
    if label:
        var color = "W" if data.color else "B"
        label.text = color + " - " + data.get_piece_type()

    update_sprite()


func update_sprite() -> void:
    if not data or not sprite_atlas or not sprite:
        return
    
    var sprite_texture = Sprites.get_sprite_texture(data.piece_type, data.color)
    # var sprite_texture = sprite_atlas.get_sprite_texture(data.piece_type, data.color)
    if sprite_texture:
        sprite.texture = sprite_texture
