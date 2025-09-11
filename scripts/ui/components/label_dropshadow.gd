# @tool
# extends Control

# @export var text: String
# @export var label: Label
# @export var viewport_container: SubViewportContainer
# @export var subviewport: SubViewport
# @export var label_shadow: Label
# @export var shadow_offset := Vector2(1.0, 3.0)
# @export var label_settings: LabelSettings


# func _ready() -> void:
#     if label_settings:
#         label.label_settings = label_settings
#         label_shadow.label_settings = label_settings
    
#     # Set the label and shadow text
#     label.text = text
#     label_shadow.text = text

#     # Set the sizes of the viewport container and viewport
#     # include the shadow's offset so the shadow doesn't get clipped
#     var label_size = label.size
#     viewport_container.custom_minimum_size = label_size + (2 * shadow_offset) # + Vector2(1.0, 1.0)
#     subviewport.size = label_size + (2 * shadow_offset)# + Vector2(1.0, 1.0)
#     label_shadow.custom_minimum_size = label_size
#     label_shadow.size = label_size

#     # Set the position of the shadow to be offset from the label

#     label_shadow.position = shadow_offset
#     print(label_shadow.position)


@tool
extends Control

@export_group("Text")
@export var text: String = "SETTINGS":
    set(value):
        text = value
        _update_labels()

@export var label_settings: LabelSettings:
    set(value):
        label_settings = value
        _update_label_settings()

@export_group("Shadow")
@export var shadow_offset: Vector2 = Vector2(1.0, 3.0):
    set(value):
        shadow_offset = value
        _update_shadow()

@export var shadow_color: Color = Color(0.0, 0.0, 0.0, 0.8):
    set(value):
        shadow_color = value
        _update_shadow()

@export var shadow_blur: float = 2.0:
    set(value):
        shadow_blur = value
        _update_shadow()

@export var use_custom_shadow: bool = true

@export_group("Nodes")
@export var main_label: Label
@export var shadow_label: Label
@export var subviewport_container: SubViewportContainer


func _ready() -> void:
    if not Engine.is_editor_hint():
        _update_labels()
        _update_label_settings()
        _update_shadow()


func _update_labels() -> void:
    if not is_inside_tree():
        return
    
    if main_label:
        main_label.text = text
    if shadow_label:
        shadow_label.text = text
    _update_subviewport.call_deferred()


func _update_label_settings() -> void:
    if not is_inside_tree():
        return
    
    if label_settings and main_label and shadow_label:
        # Create a copy for the shadow with different color
        var shadow_settings = label_settings.duplicate()
        shadow_settings.font_color = shadow_color
        
        main_label.label_settings = label_settings
        shadow_label.label_settings = shadow_settings


func _update_shadow() -> void:
    if not is_inside_tree():
        return
    
    if use_custom_shadow and shadow_label:
        shadow_label.position = shadow_offset
        # Apply blur shader if needed
        if shadow_blur > 0:
            _update_blur_shader()
    else:
        # Use built-in shadow
        if main_label and label_settings:
            # TODO: fix this, there is no `shadow_offset_x` or `shadow_offset_y`
            label_settings.shadow_offset_x = int(shadow_offset.x)
            label_settings.shadow_offset_y = int(shadow_offset.y)
            label_settings.shadow_color = shadow_color


func _update_blur_shader() -> void:
    if not shadow_label:
        return
    
    shadow_label.material.set_shader_parameter("blur_amount", shadow_blur)
    shadow_label.material.set_shader_parameter("samples", 25.0)


func _update_subviewport() -> void:
    var ts = get_text_size()
    subviewport_container.custom_minimum_size = Vector2(ts.x, ts.y + shadow_offset.y)
    subviewport_container.size = Vector2(ts.x, ts.y + shadow_offset.y)
    subviewport_container.position = main_label.position


func get_text_size() -> Vector2:
    if main_label and label_settings:
        return label_settings.font.get_string_size(text, HORIZONTAL_ALIGNMENT_CENTER, -1, label_settings.font_size)
    return Vector2.ZERO


func _notification(what: int) -> void:
    if what == NOTIFICATION_RESIZED:
        _update_shadow()
