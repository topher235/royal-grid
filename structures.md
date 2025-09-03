# Structures

These are the data structures for entities found throughout the game.

## Piece Data

- type: (enum) the type of piece it is (pawn, rook, etc.). Used to determine rulesets, sprite, etc.
- points: (int) the number of points awarded if this piece is used to capture another


## Effect Data

- name: (str) the name of the effect. Used to instantiate effect resources.
- position: (Vector2) the position of the effect on the board
- duration: (int) remaining number of turns until it expires

## Active game

- tiles: 2D array of booleans. If true, the tile is available. If false, the tile is blacked out.
- effects: array
  - id
  - position (vector2)
  - remaining_duration
- pieces: array of piece data on the board
  - piece_type
  - position (vector2)
- score: int of the current score
- map_id: id of the map used
- character_id: id of the character used

## Map

- id: (int) id of the map so it can be referenced
- name: (str) the name of the map
- positions: 2D array of Vector2 positions where the tiles are blacked out

## Character

- id: (int) id of the character so it can be referenced
- name: (str) the name of the character
- icon: (Texture) sprite of the character
- effect: (CharacterEffect) the passive effect the character provides the player


## Save file

- active_game: nullable. The active game data. If null, then no active game in progress.
- stats: player statistics across all playtime
  - num_games_played
  - best_score
- currency: the amount of currency the user has
- purchases: array
  - purchase_id
  - item_id
  - has_saved
- should_show_ads: boolean. If true, then show ads.


## Inventory file

Maybe these can be resource files and then the game can update the resource and save that directly.

- characters
  - id
  - is_unlocked
  - cost
- maps
  - id
  - is_unlocked
  - cost
