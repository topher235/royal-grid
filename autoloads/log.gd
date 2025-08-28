extends Node

enum LogLevel {
    INFO,
    DEBUG,
    WARNING,
    ERROR,
    NONE,
}

const LEVEL = LogLevel.ERROR

func info(node, message) -> void:
    if LEVEL <= LogLevel.INFO:
        print(node.name, " -- ", message)


func error(node, message) -> void:
    if LEVEL <= LogLevel.ERROR:
        printerr(node.name, " -- ", message)
