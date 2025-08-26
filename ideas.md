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




- [ ] Add a small pulse animation to effects
- [ ] Change effect spawn to spawn a king or queen and use the crown icon. then take out the king and queen from the normal weights
- [ ] Add effect that rotates the board, but makes the new top-left tile (0, 0)
- [ ] Add other effects to the spawn weights
