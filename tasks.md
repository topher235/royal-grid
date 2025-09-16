# Tasks

## To MVP

- [X] Implement **Settings** modal
  - [X] User can enable/disable sound & music
  - [X] Modal is opened from Main Menu
  - [X] When closed, the reverse animation plays
- [ ] Implement **Shop** modal
  - [ ] Tabbed shop design for characters, maps, cosmetics, and IAP
  - [ ] Available stock is loaded from Resource files
  - [ ] User can purchase item and it is saved in their save file
  - [ ] When closed, the reverse animation plays
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
  - [ ] Add animation to carousel movement
  - [ ] Add sound to button clicks
  - [X] Connect Rush/Classic buttons to the Game scene with the options set in the GameConfig
  - [X] Extract currency bars into separate scene
  - [X] Load currency into UI from save file
  - [ ] Find new icon for the special currency
- [ ] Gameplay
  - [X] Implement special effects from Characters
  - [ ] Implement RUSH mode with spawn on a timer
    - [ ] Fix race condition bug where a piece can spawn where a player wants to go, overwriting the movement. Might want some form of transaction lock on the tile.
  - [ ] Add rotate board special effect
  - [ ] Implement game over logic for both CLASSIC and RUSH modes
- [ ] Game Level UI
  - [X] Re-design tiles to use the new isometric art
  - [ ] Add shadow to tile scene for 3d effect
  - [ ] Use new pixel art pieces
  - [ ] Add Character portrait
  - [ ] Add modal for game over
  - [ ] Add pause menu
    - [ ] Ensure RUSH mode pauses its spawning when the pause menu is opened
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


## Later

- [ ] Find better UI sounds
  - [ ] Click, Modal Open, and Modal Close


## Maybe Tasks

- [ ] A node component that resizes a label based on its length. This is for languages that take up more size than English.
- [ ] Different fonts for other languages, i.e. Chinese characters, Spanish/French accents, etc.
