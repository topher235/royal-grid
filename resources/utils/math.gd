class_name Math extends RefCounted


static func calculate_center(node: Node) -> Vector2:
    return Vector2(node.size.x / 2, node.size.y / 2)
