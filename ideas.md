# Ideas

## Difficulty Modifiers

- Event System
  - To introduce randomness and difficulty to plan around, there could be an event system that causes events to occur at random or pre-determined intervals. For example, once every 5 moves, an extra piece will spawn on the board.

- Can't move the same piece 2x in a row

- Variable spawn rate
  - As the player captures more pieces, the game could spawn more than 1 piece per turn or always spawn new pieces 
  - As the game progresses, the weights for each piece could change, e.g. queen becomes less likely to spawn since it's easier to capture pieces with that one

- Turn order
  - Instead of ANY legal chess move, the player will have to follow a white-black turn order

- Power-ups
  - After a piece captures 3 pieces, it upgrades into a more powerful piece, e.g. pawn -> rook

- Environment hazards/rewards
  - Periodically place effects on tiles that will affect other aspects of the game
  - Example of hazard: if piece is moved to a bomb tile, then the game is over (or just can't go there)
  - Example of reward: if a piece is moved to a reward tile, then the next X turns have 2x point multiplier

- Time trial
  - New piece appears after X seconds instead of every move

- Characters
  - Play as a character that gives special effects
  - Beggar: makes pawns give 10 points when they take a non-pawn piece
  - Captain: More likely to spawn knights


- Progression
  - Give a currency when the game is over based on the points scored
  - Currency can be used to purchase new tile effects and characters
  - Rewarded ads for currency

- Shop
  - Buy currency to unlock effects and characters without going through progression system
  - Buy ad removal






- [X] Add a small pulse animation to effects
- [X] Change effect spawn to spawn a king or queen and use the crown icon. then take out the king and queen from the normal weights
- [ ] Add effect that rotates the board, but makes the new top-left tile (0, 0)
- [X] Add other effects to the spawn weights
- [ ] Make effects have a chance to happen every move, but chance grows each time no effect is spawned
- [ ] Add frozen animation for user feedback when they try to press a frozen piece
- [X] Fix bomb effect animating before move indicator is hidden
- [X] Preview upcoming piece
- [ ] Fix effects spawning under units
- [ ] FIX - effects and pawns are using the same `is_occupied` flag on Tile, but they are not compatible in the current use. Effects should not spawn where there are units but if a unit is spawned where there is an effect, then the effect should be removed (expired, not executed). Sharing the flag means it's set to null when an effect is removed and a piece is still there. 


Todo today:

- [X] Set up SceneManager and make a Main scene -> MainMenu -> GameUI
- [X] Add frozen animation
- [X] Add multiplier label to UI
- [X] Fix effect/piece `is_occupied` duplication
- [ ] Fix spawner effect spawning onto same spot the piece is being moved to
