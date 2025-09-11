extends Control

signal closed

@export_group("Nodes")
@export var stats_vbox_container: VBoxContainer
@export var animation_player: AnimationPlayer

var ps: PlayerStats


func _ready() -> void:
    ps = SaveManager.retrieve_stats()
    initialize_stat_labels()
    open()


func initialize_stat_labels() -> void:
    """
    Relies on the PlayerStats class to define what gets displayed here. Dynamically
    creates rows in the VBoxContainer with appropriate label settings rather than setting
    things up in the editor.

    Could be improved with sections, e.g. "Gameplay" vs "Captures".
    """
    if not ps:
        return
    
    for row in stats_vbox_container.get_children():
        row.queue_free()
    
    var stats_dict = ps.get_display_values()
    for key in stats_dict.keys():
        var value = stats_dict[key]

        var k_label = Label.new()
        k_label.text = key
        var ls = LabelSettings.new()
        ls.font_size = 8
        k_label.label_settings = ls
        k_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
        k_label.size_flags_horizontal = SIZE_EXPAND_FILL

        var v_label = Label.new()
        v_label.text = str(value)
        v_label.label_settings = ls
        v_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
        v_label.size_flags_horizontal = SIZE_EXPAND_FILL

        var row = HBoxContainer.new()
        row.add_child(k_label)
        row.add_child(v_label)
        stats_vbox_container.add_child(row)


func open() -> void:
    animation_player.play("open")


func _on_close_button_pressed() -> void:
    animation_player.play_backwards("open")
    await animation_player.animation_finished
    closed.emit()
