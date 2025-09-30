# Tasks

## To MVP

- [X] Add SafeArea margins
- [X] Implement **Settings** modal
  - [X] User can enable/disable sound & music
  - [X] Modal is opened from Main Menu
  - [X] When closed, the reverse animation plays
- [X] Implement **Shop** modal
  - [X] Says "Under Construction"
- [ ] Transitions
  - [X] Scene transition, checkerboard swipe
- [ ] Main Menu
  - [X] Add sounds to button clicks
  - [X] Add move sound to chess piece animation
  - [X] Call `open_modal` function in `to_shop` animation at 0.3s
  - [X] Connect New Game to ConfigLoadout scene
  - [ ] Set Continue Game button when there is an active game
- [ ] Config Loadout
  - [X] Implement the config carousels as a scene
    - [ ] Show all options (even unpurchased)
    - [ ] Give player options to unlock at this screen
  - [X] Add animation to carousel movement
  - [ ] Add sound to button clicks
  - [ ] Add sound to carousel movement
  - [X] Connect Rush/Classic buttons to the Game scene with the options set in the GameConfig
  - [X] Extract currency bars into separate scene
  - [X] Load currency into UI from save file
  - [ ] Find new icon for the special currency - crowns?
- [ ] Gameplay
  - [X] Implement special effects from Characters
  - [X] Implement RUSH mode with spawn on a timer
  - [ ] Fix race condition bug where a piece can spawn where a player wants to go, overwriting the movement. Might want some form of transaction lock on the tile.
  - [X] Add rotate board special effect
  - [X] Implement game over logic for both CLASSIC and RUSH modes
  - [X] Fix bomb effect not showing destroy particle animation. It was a z-index bug.
  - [X] New icon for rotate special effect
  - [X] Fix bomb effect when piece spawn in bomb radius. Looks like it's capturing an empty space.
  - [X] Fix piece grid_position after moving onto a rotate effect. Piece still has old pre-rotated position
  - [X] Add difficulty progression within a single game
    - [X] Chance of spawning multiple pieces after X moves. Need to update logic and UI to handle multiple pieces.
    - [X] Change effect/piece spawn weights based on number of moves
  - [X] Change RUSH mode to use a chess timer and make a character that spawns on a timer
  - [ ] Award coins based on score
  - [ ] Add coin effect - appears on the board like a normal effect but gives coins at game end
- [ ] Game Level UI
  - [X] Re-design tiles to use the new isometric art
  - [X] Add shadow to tile scene for 3d effect
  - [ ] Use new pixel art pieces
  - [ ] Add Character portrait
  - [ ] Add modal for game over
  - [ ] Add pause menu
    - [X] Ensure RUSH mode pauses its spawning when the pause menu is opened
  - [X] Add animation counting points down to 0 and score up to the current score 
- [ ] Stats modal
  - [X] Display player stats
  - [X] When closed, play reverse animation
  - [ ] Finish implementing PlayerStats.get_display_values
  - [ ] Decide on stats section headers
- [ ] Localization
  - [ ] Set up localization patterns while there is little text
  - [ ] Player can select language on first start
  - [X] Player can select language from settings menu
  - [ ] Test string length to ensure characters don't overflow their container

## Bugs

- [ ] Tiles should not be clickable once game is over

## Later

- [ ] Find better UI sounds
  - [ ] Click, Modal Open, and Modal Close
- [ ] Implement **Shop** modal
  - [ ] Tabbed shop design for characters, maps, cosmetics, and IAP
  - [ ] Available stock is loaded from Resource files
  - [ ] User can purchase item and it is saved in their save file
  - [ ] When closed, the reverse animation plays
- [ ] Add way to rotate counter-clockwise


## Maybe Tasks

- [ ] A node component that resizes a label based on its length. This is for languages that take up more size than English.
- [ ] Different fonts for other languages, i.e. Chinese characters, Spanish/French accents, etc.
