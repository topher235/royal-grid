extends Node

const SAVE_FILE_LOCATION := "res://savefile.json"
const DEFAULT_SAVE_DATA := {
    "active_game": null,
    "stats": {
        "num_games_played": 0,
        "best_score": 0,
    },
    "coins": 0,
    "gems": 0,
    "purchases": [],
    "should_show_ads": true,
}

var current_state = DEFAULT_SAVE_DATA.duplicate(true)


func _ready() -> void:
    load_game()


func load_game() -> void:
    """
    Tries to load the save file into `current_state`. If we cannot,
    e.g. the file does not exist, then save the default save data to the
    save file location.
    """
    var file = FileAccess.open(SAVE_FILE_LOCATION, FileAccess.READ)
    if file == null:
        Log.info(self, "No save file found, using default data")
        save_game()
        return
    
    var json_string = file.get_as_text()
    file.close()

    var json = JSON.new()
    var parse_result = json.parse(json_string)

    if parse_result != OK:
        Log.error(self, "Failed to parse save file: " + json.get_error_message())
        save_game()
        return
    
    var data = json.get_data()
    if data == null:
        Log.error(self, "Save file data is null")
        save_game()
        return
    
    current_state = data
    Log.info(self, "Save file loaded successfully")


func save_game() -> void:
    """
    Saves the `current_state` contents to a json file on the file system.
    """
    var json_string = JSON.stringify(current_state)

    var file = FileAccess.open(SAVE_FILE_LOCATION, FileAccess.WRITE)
    if file == null:
        Log.error(self, "Failed to open save file for writing")
        return
    
    file.store_string(json_string)
    file.close()
    Log.info(self, "Game saved successfully")


func update_active_game(game_data: ActiveGameData) -> void:
    """
    Serializes the game data to the `active_game` field in the `current_state`.
    """
    if game_data == null:
        current_state["active_game"] = null
    else:
        current_state["active_game"] = game_data.serialize()
    
    save_game()


func retrieve_active_game() -> ActiveGameData:
    """
    Deserializes the `active_game` in the `current_state` into an ActiveGameData
    object.
    """
    if current_state["active_game"] == null:
        return null
    
    var active_game_data = ActiveGameData.new()
    var data = current_state["active_game"]
    active_game_data.deserialize(data)
    return active_game_data


func clear_active_game() -> void:
    """
    Clears the active game from the save data.
    """
    current_state["active_game"] = null
    save_game()


func has_active_game() -> bool:
    """
    Returns true if there is an active game in progress.
    """
    return current_state["active_game"] != null


func update_stats(player_stats: PlayerStats) -> void:
    """
    Updates player statistics.
    """
    current_state["stats"] = player_stats.serialize()
    save_game()


func retrieve_stats() -> PlayerStats:
    """
    Returns the current player statistics.
    """
    var player_stats = PlayerStats.new()
    var data = current_state["stats"]
    player_stats.deserialize(data)
    return player_stats


func update_coins(amount: int) -> void:
    """
    Updates the player's coins.
    """
    current_state["coins"] += amount
    save_game()


func get_coins() -> int:
    """
    Returns the current coin amount.
    """
    return current_state["coins"]
    
    
func update_gems(amount: int) -> void:
    """
    Updates the player's gems.
    """
    current_state["gems"] += amount
    save_game()
    
    
func get_gems() -> int:
    """
    Returns the current gem amount.
    """
    return current_state["gems"]
    
