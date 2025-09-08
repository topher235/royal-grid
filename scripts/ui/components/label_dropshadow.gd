extends Control

@export var text: String
@export var label: Label
@export var viewport_container: SubViewportContainer
@export var subviewport: SubViewport
@export var label_shadow: Label


func _ready() -> void:
    # Set the label and shadow text
    label.text = text
    label_shadow.text = text

    # Set the sizes of the viewport container and viewport
    # include the shadow's offset so the shadow doesn't get clipped
    var label_size = label.size
    var shadow_offset = Vector2(1.0, 3.0)
    viewport_container.custom_minimum_size = label_size + shadow_offset
    subviewport.size = label_size + shadow_offset

    # Set the position of the shadow to be offset from the label
    label_shadow.position = shadow_offset
