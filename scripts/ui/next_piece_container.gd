extends PanelContainer

const CHESS_PIECE = preload("res://scenes/pieces/chess_piece.tscn")

var hbox: HBoxContainer


func _ready() -> void:
    # TODO: use the $ symbol or whatever the appropriate shortcut is
    hbox = get_child(0)
    
    Events.next_piece_is_spawning.connect(_on_next_piece_is_spawning)
    Events.next_piece_generated.connect(_on_next_piece_generated)


func _on_next_piece_is_spawning() -> void:
    # structure looks like 'self -> HBoxContainer -> Control -> ChessPiece'
    for child in hbox.get_children():
        var piece = child.get_child(0)
        if piece is ChessPiece:
            piece.fadeout()
        child.queue_free()


func _on_next_piece_generated(piece_data: PieceSpawnData) -> void:
    # create a block so that the HBox will handle auto-layouts
    var block: Control = Control.new()
    block.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    
    # create the piece UI and add it to the block control node
    var piece: ChessPiece = CHESS_PIECE.instantiate() as ChessPiece
    piece.data = piece_data
    block.add_child(piece)
    
    # add the block to the HBox
    hbox.add_child(block)

    # start the animation
    piece.animate_spawn()
