class_name SpawnRulesModifier extends BaseModifier

@export var piece_type: PieceSpawnData.PieceType


func _init() -> void:
    modifier_type = Type.SPAWN_RATE
    
