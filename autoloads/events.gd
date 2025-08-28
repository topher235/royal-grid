extends Node

@warning_ignore_start("unused_signal")

signal score_updated(new_score: int)
signal mult_updated(new_mult: int)
signal next_piece_is_spawning
signal next_piece_generated(piece_data: PieceSpawnData)

@warning_ignore_restore("unused_signal")