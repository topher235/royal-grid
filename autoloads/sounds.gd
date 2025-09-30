extends Node


const CLICK = preload("res://assets/audio/ui/click_0.wav")
const CLICK_1 = preload("res://assets/audio/ui/click_1.wav")
const MOVE = preload("res://assets/audio/sfx/PieceMove1.wav")
const HOVER = preload("res://assets/audio/sfx/Hover2.wav")
const SPAWN = preload("res://assets/audio/sfx/Spawn.wav")
const TYPING = preload("res://assets/audio/sfx/Typing.wav")
const MODAL_OPEN = preload("res://assets/audio/sfx/ModalOpen.wav")
const MODAL_CLOSE = preload("res://assets/audio/sfx/ModalClose.wav")

enum SoundType {
    CLICK,
    CLICK_1,
    MOVE,
    HOVER,
    SPAWN,
    TYPING,
    MODAL_OPEN,
    MODAL_CLOSE,
}

func get_sound_from_type(sound_type: SoundType) -> AudioStream:
    # NOTE: this only works when the const variable name matches the SoundType
    #   enum name exactly
    var sound_name = SoundType.keys()[sound_type]
    return get(sound_name)
