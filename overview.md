# Royal Grid

Royal Grid is a small, mobile game created in Godot 4.4

## Gameplay

The player starts the game and is provided with a 5x5 grid with a set of black and white chess pieces on random tiles. Each turn the player can make ANY legal chess move. If the player captures a piece, then they can take another turn immediately. If a player does not take a piece, then a random piece is added to a random unoccupied tile. The game ends when the player cannot make a move or a new piece cannot be placed.

## Scene Architecture

- GameBoard
  - Grid representation
  - Tile state management
  - Grid validation and bounds checking
- Tile
  - Visual representation of a board tile
  - Has a variety of states, i.e. normal, selected, valid_move, etc.
  - May or may not have a chess piece as a child
- ChessPiece
  - Visual representation of a chess piece
