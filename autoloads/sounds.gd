extends Node


const CLICK = preload("res://assets/audio/sfx/PieceImpact2.wav")
const MOVE = preload("res://assets/audio/sfx/PieceMove1.wav")
const HOVER = preload("res://assets/audio/sfx/Hover2.wav")
const SPAWN = preload("res://assets/audio/sfx/Spawn.wav")
const TYPING = preload("res://assets/audio/sfx/Typing.wav")

enum SoundType {
    CLICK,
    MOVE,
    HOVER,
    SPAWN,
    TYPING,
}

func get_sound_from_type(sound_type: SoundType) -> AudioStream:
    # NOTE: this only works when the const variable name matches the SoundType
    #   enum name exactly
    var sound_name = SoundType.keys()[sound_type]
    return get(sound_name)
