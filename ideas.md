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
    - ** Don't like this idea

- Power-ups
  - After a piece captures 3 pieces, it upgrades into a more powerful piece, e.g. pawn -> rook

- Environment hazards/rewards
  - Periodically place effects on tiles that will affect other aspects of the game
  - Example of hazard: if piece is moved to a bomb tile, then the game is over (or just can't go there)
  - Example of reward: if a piece is moved to a reward tile, then the next X turns have 2x point multiplier
  - How should extra multipliers be applied? Should duration be reset or should each application of multiplier be its own effect even after others are applied? For example, if a player activates a +1 and then the duration is set to last for 5 turns and the player activates a +1 on the next turn, should the duration be 5, 9, or a separate instance of 4 and 5?

- Time trial
  - New piece appears after X seconds instead of every move

- Characters
  - Play as a character that gives special effects
  - Beggar: makes pawns give 10 points when they take a non-pawn piece
  - Captain: More likely to spawn knights
  - Assassin: Gives more points when taking Queens and Kings
  - Gains points when no capture; loses points when capture


- Increasing difficulty
  - Chess timer: timer starts at 25s and capturing a piece adds 5s to the timer. Game over when time runs out.
  - Spawning multiple pieces: After X moves, the spawner will start spawning 2 or 3 pieces at a time to clog up the board.
  - Event system: random events, i.e. piece spawns, board shuffle, negative score multiplier
  - Changing effect/piece spawn weights



- Maps
  -  The usual 4x4 grid where positions [(1, 2), (2, 3), (3, 3)] are blacked out (no effects, no pieces, etc. can be placed there)
  - The background behind the board can change


- Progression
  - Give a currency when the game is over based on the points scored
  - Currency can be used to purchase new tile effects and characters
  - Rewarded ads for currency

- Shop
  - Buy currency to unlock effects, characters, and maps without going through progression system
  - Buy cosmetics, e.g. new piece sprites, new board design, new animations
  - Buy ad removal
  - Bundles
    - One-time beginner bundle that is cheaper, could include coins, diamonds, 1 chess set cosmetic, etc.
    - Ad removal bundled with coins


- Tutorial explain on first load
  - Cycle through the basics in a carousel of illustrations


- Easy/tutorial mode
  - Player presses a piece and the game shows valid positions + a preview of points that will be awarded when the player captures the other piece


- Statistics
  - Number of games played
  - Best score
  - Average score
  - Number of pieces captured


- Transfer data
  - User should be given some way to transfer data
  - Stored on server with a temporary login (24 hours?)
  - Export/import file with encrypted contents
  - Google play / apple cloud backup


- Achievements
  - Apparently achievements are popular
  - e.g. "Pawn master": Captured 150 pawns



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


Todo:

- [ ] Game continue needs to use map_id instead of the current game config
- [ ] TileUI and ChessPiece need to scale with grid size. 40px ends up off-screen in a 5x5 grid

