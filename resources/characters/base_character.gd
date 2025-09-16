class_name BaseCharacter extends Resource

@export var name: String
@export var effect_description: String
@export var avatar: Texture
@export var priority: int = 0  # Used to order in config selection, higher priority will be closer to front of list
@export var modifiers: Array[BaseModifier] = []
