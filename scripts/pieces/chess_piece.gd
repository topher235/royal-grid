@tool
class_name ChessPiece extends Node2D

const WHITE_OUTLINE_COLOR = Color8(152, 59, 202)
const BLACK_OUTLINE_COLOR = Color8(0, 145, 45)
const OUTLINE_SHADER_MATERIAL = preload("res://resources/shader_materials/chess_piece_outline.tres")

@export var animator: PieceAnimator
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
    if not data:
        return
    
    if label:
        var color = "W" if data.color else "B"
        label.text = color + " - " + data.get_piece_type()

    update_sprite()
    update_outline_shader_color()


func update_sprite() -> void:
    if not data or not sprite_atlas or not sprite:
        return
    
    var sprite_texture = Sprites.get_sprite_texture(data.piece_type, data.color)
    # var sprite_texture = sprite_atlas.get_sprite_texture(data.piece_type, data.color)
    if sprite_texture:
        sprite.texture = sprite_texture


func update_outline_shader_color() -> void:
    if data and sprite:
        var outline_color = WHITE_OUTLINE_COLOR if data.color else BLACK_OUTLINE_COLOR
        sprite.material.set_shader_parameter("color", outline_color)


func animate_move_to(to_pos) -> void:
    await animator.animate_move_to(to_pos)
    toggle_outline(false)


func animate_spawn() -> void:
    animator.animate_spawn()


func animate_capture() -> void:
    animator.animate_capture()


func animate_error() -> void:
    sprite.material = null
    animator.animate_error(
        func():
            sprite.material = OUTLINE_SHADER_MATERIAL.duplicate()
            update_outline_shader_color()
    )


func toggle_outline(is_enabled: bool) -> void:
    if sprite and sprite.material:
        sprite.material.set_shader_parameter("enable_outline", float(is_enabled))
