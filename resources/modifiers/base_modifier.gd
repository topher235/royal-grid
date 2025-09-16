class_name BaseModifier extends Resource

enum Type {
    SPAWN_RATE,
}

enum Operation {
    ADD,
    SUBTRACT,
    MULTIPLY,
    SET,
}

@export var modifier_type: Type
@export var value: float
@export var operation: Operation

