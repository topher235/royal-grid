class_name PlayerStats extends Resource

var num_games_played: int
var best_score: int


func serialize() -> Dictionary:
    return {
        "num_games_played": num_games_played,
        "best_score": best_score,
    }


func deserialize(data: Dictionary) -> void:
    num_games_played = data["num_games_played"]
    best_score = data["best_score"]


func calculate_best_score(current_score: int) -> void:
    if current_score > best_score:
        best_score = current_score
