extends Node

signal game_state_changed(new_state)
signal turn_ended

enum GameState {MAIN_MENU, PLAYING, PAUSED, GAME_OVER}

var current_state: GameState = GameState.MAIN_MENU
var game_board: Node2D


func _ready() -> void:
    game_board = get_tree().get_first_node_in_group("gameboard")
    if game_board:
        print("Game board found and connected")
    else:
        printerr("Warning: Game board not found")


func start_game() -> void:
    current_state = GameState.PLAYING
    game_state_changed.emit(current_state)
    print("Game Started")


func end_turn() -> void:
    turn_ended.emit()
