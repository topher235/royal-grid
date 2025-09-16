extends Control

@export var amount := 0:
    set = _set_amount

@export_group("Nodes")
@export var amount_label: Label


func _ready() -> void:
    amount = SaveManager.get_coins()
    Events.coin_amount_updated.connect(_on_coin_amount_updated)


func _set_amount(value: int) -> void:
    amount = value
    amount_label.text = str(amount)
    
    
func _on_coin_amount_updated() -> void:
    amount = SaveManager.get_coins()
    