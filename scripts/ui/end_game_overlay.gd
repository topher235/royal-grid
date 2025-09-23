class_name EndGameOverlay extends Control

@export var coins_label: Label

var coins: int


func animate_coins() -> void:
    Log.info(self, "Counting from " + str(0) + " to " + str(coins))
    animate_counting_label(coins_label, 0, coins)


func animate_counting_label(label: Label, from_num: int, to_num: int) -> void:
    """
    Utility function for animating a counting label. A "counting" label is one that rapidly increments its
    text from 1 number to another.
    
    Could be improved with a class-scoped tween, so we can have more control over the animations. For example,
    if a player scores more points while the label is counting, we might end up with 2 tweens affecting the
    same node.
    """
    # Determine whether we are counting up or down
    var greater := maxi(from_num, to_num)
    var lesser := mini(from_num, to_num)
    var increment_direction := 1 if to_num - from_num >= 0 else -1
    # Configure the tween
    var tween: Tween = create_tween()
    var steps := greater - lesser
    var total_time := 0.5
    var step_delay := float(total_time / steps)
    var min_pitch := 0.9
    var max_pitch := 1.1
    var current_num := from_num
    for i in range(1, steps + 1):
        # we have to increment the current_num outside of the tween callback, otherwise
        # it will have a snapshot of what it was, and it will only increment 1x
        current_num += increment_direction
        tween.parallel().tween_callback(
            func():
                var pitch := min_pitch + (randf() * (max_pitch - min_pitch))
                SoundManager.play_ui_sound_with_pitch(Sounds.TYPING, pitch)
                label.text = "" + str(current_num)
        ).set_delay(step_delay * i)