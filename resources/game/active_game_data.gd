class_name ActiveGameData extends Resource

@export var tiles: Array[ActiveTileData]
@export var effects: Array[ActiveEffectData]
@export var pieces: Array[ActivePieceData]
@export var next_piece: ActivePieceData
@export var score: int
@export var map_id: int
@export var character_id: int
@export var mult: int
@export var mult_duration: int
@export var stats: PlayerStats


func serialize() -> Dictionary:
    var active_tiles = []
    for tile in tiles:
        active_tiles.append(tile.serialize())
    
    var active_effects = []
    for effect in effects:
        active_effects.append(effect.serialize())
    
    var active_pieces = []
    for piece in pieces:
        active_pieces.append(piece.serialize())
    
    return {
        "tiles": active_tiles,
        "effects": active_effects,
        "pieces": active_pieces,
        "next_piece": next_piece.serialize(),
        "score": score,
        "mult": mult,
        "mult_duration": mult_duration,
        "map_id": map_id,
        "character_id": character_id,
        "stats": stats.serialize(),
    }


func deserialize(data: Dictionary) -> void:
    """
    Deserializes data from a Dictionary into this ActiveGameData object.
    """
    score = data.get("score", 0)
    mult = data.get("mult", 1)
    mult_duration = data.get("mult_duration", 0)
    map_id = data.get("map_id", 0)
    character_id = data.get("character_id", 0)

    next_piece = ActivePieceData.new()
    next_piece.deserialize(data.get("next_piece", {}))

    # Deserialize tiles
    tiles = []
    var tiles_data = data.get("tiles", [])
    for tile_data in tiles_data:
        var tile = ActiveTileData.new()
        tile.deserialize(tile_data)
        tiles.append(tile)
    
    # Deserialize effects
    effects = []
    var effects_data = data.get("effects", [])
    for effect_data in effects_data:
        var effect = ActiveEffectData.new()
        effect.deserialize(effect_data)
        effects.append(effect)
    
    # Deserialize pieces
    pieces = []
    var pieces_data = data.get("pieces", [])
    for piece_data in pieces_data:
        var piece = ActivePieceData.new()
        piece.deserialize(piece_data)
        pieces.append(piece)
    
    # Deserialize stats
    var stats_data = data.get("stats", {})
    stats = PlayerStats.new()
    stats.deserialize(stats_data)
