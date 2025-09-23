class_name CoinCalculator extends RefCounted


static func calculate(points: int) -> int:
    # TODO: make this more sophisticated
    if points < 10:
        return 0
    elif points < 25:
        return 25
    elif points < 50:
        return 50
    else:
        return 75
