class_name SpawnOnTimerModifier extends BaseModifier

# whether or not the spawn rules should spawn every X seconds
@export var spawn_on_timer := false

# the interval in which pieces are spawned, in seconds
@export var spawn_frequency_in_seconds := 1


func _init() -> void:
    modifier_type = Type.SPAWN_ON_TIMER
