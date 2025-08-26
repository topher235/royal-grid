class_name EffectSpawnData extends Resource

@export var position: Vector2i
@export var effect: SpecialEffect
@export var weights: Dictionary = {
    "blocking": 0.4,
    "multiplier": 0.1,
    "spawn": 0.2,
    "freeze": 0.3,
    "bomb": 0.3,
}

var rng: RandomNumberGenerator


func _init(_position: Vector2i, _effect: SpecialEffect = null) -> void:
    position = _position
    effect = _effect
    rng = RandomNumberGenerator.new()
    
    if _effect == null:
        init_random_effect()



func init_random_effect() -> void:
    if weights.is_empty():
        effect = BlockingSpecialEffect.new()
        return
    
    var total_weight = 0.0
    for weight in weights.values():
        total_weight += weight
    
    if total_weight <= 0:
        effect = BlockingSpecialEffect.new()
        return
    
    var random_value = rng.randf() * total_weight

    var current_weight = 0.0
    for effect_name in weights.keys():
        current_weight += weights[effect_name]
        if random_value <= current_weight:
            match effect_name:
                "blocking":
                    effect = BlockingSpecialEffect.new()
                    break
                "multiplier":
                    effect = MultiplierSpecialEffect.new()
                    break
                "spawn":
                    effect = SpawnSpecialEffect.new()
                    break
                "freeze":
                    effect = FreezeSpecialEffect.new()
                    break
                "bomb":
                    effect = BombSpecialEffect.new()
                    break

    # Fallback to blocking effect    
    if effect == null:
        effect = BlockingSpecialEffect.new()
