class_name ChessSpriteAtlas extends Resource

# The spritesheet texture
@export var spritesheet: Texture2D

# Sprite dimensions (assuming each piece is 16x16 pixels)
@export var sprite_width: int = 16
@export var sprite_height: int = 16

# Get the sprite region for a specific piece type and color
func get_sprite_region(piece_type: PieceSpawnData.PieceType, color: bool) -> Rect2:
    var column: int
    var row: int = 0 if color else 1  # 0 = white, 1 = black
    
    # Map piece types to columns
    match piece_type:
        PieceSpawnData.PieceType.KING:
            column = 0
        PieceSpawnData.PieceType.QUEEN:
            column = 1
        PieceSpawnData.PieceType.BISHOP:
            column = 2
        PieceSpawnData.PieceType.KNIGHT:
            column = 3
        PieceSpawnData.PieceType.ROOK:
            column = 4
        PieceSpawnData.PieceType.PAWN:
            column = 5
    
    var x = column * sprite_width
    var y = row * sprite_height
    return Rect2(x, y, sprite_width, sprite_height)

# Get an AtlasTexture for a specific piece
func get_sprite_texture(piece_type: PieceSpawnData.PieceType, color: bool) -> AtlasTexture:
    var atlas_texture = AtlasTexture.new()
    atlas_texture.atlas = spritesheet
    atlas_texture.region = get_sprite_region(piece_type, color)
    return atlas_texture
