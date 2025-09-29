extends PanelContainer

const CHESS_PIECE = preload("res://scenes/pieces/chess_piece.tscn")

var timer: Timer
var hbox: HBoxContainer
var add_queue: Array[PieceSpawnData] = []
var is_animating: bool = false


func _ready() -> void:
    # TODO: use the $ symbol or whatever the appropriate shortcut is
    hbox = get_child(0)
    
    Events.next_piece_is_spawning.connect(_on_next_piece_is_spawning)
    Events.next_piece_generated.connect(_on_next_piece_generated)


func _on_next_piece_is_spawning() -> void:
    """
    When pieces are spawned on the board, we need to delete them from this preview container,
    so we go through the children and call their `fadeout` animation.
    """
    # structure looks like 'self -> HBoxContainer -> Control -> ChessPiece'
    for child in hbox.get_children():
        var piece = child.get_child(0)
        if piece is ChessPiece:
            piece.fadeout()
        child.queue_free()


func _on_next_piece_generated(piece_data: PieceSpawnData) -> void:
    """
    Add the new data to the queue for processing. If not already animating, kick off the animating process.
    """
    add_queue.append(piece_data)
    if not is_animating:
        _animate_next_piece_generated()

    
func _animate_next_piece_generated() -> void:
    """
    Until the queue of data is empty, instantiate the chess pieces and add them to the container. Add a 
    slight delay between each instantiation and set the `is_animating` flag to false once we're done.
    """
    if add_queue.is_empty():
        is_animating = false
        return

    is_animating = true
    
    var piece_data: PieceSpawnData = add_queue.pop_front()
    # create a block so that the HBox will handle auto-layouts
    var block: Control = Control.new()
    
    # create the piece UI and add it to the block control node
    var piece: ChessPiece = CHESS_PIECE.instantiate() as ChessPiece
    piece.data = piece_data
    block.add_child(piece)
    var piece_size := piece.sprite.custom_minimum_size
    block.custom_minimum_size = Vector2(piece_size.x * 0.6, piece_size.y * 0.9)
    
    # add the block to the HBox
    hbox.add_child(block)

    # start the animation
    piece.animate_spawn()
    
    get_tree().create_timer(0.15).timeout.connect(_animate_next_piece_generated)
