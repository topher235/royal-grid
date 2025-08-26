class_name SpecialEffect extends Resource

signal end_effect

var duration := -1  # forever
# Can toggle this to 'false' if we want a "blocking" effect
var can_piece_move_to := true

# this field is for prototyping, replace with sprite or something
var color: Color = Color.WHITE
var name := "BASE"
var icon: Texture2D


func execute(_gm: GameManager, _pos: Vector2i) -> void:
    print("Executing - ", name)
    pass


func decrement_duration(gm: GameManager) -> void:
    if duration < 0:
        # lasts forever
        return
    
    duration -= 1
    if duration < 0:
        expire(gm)


func expire(_gm: GameManager) -> void:
    end_effect.emit()
