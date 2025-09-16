extends Node2D


func _ready() -> void:
    # Set user's preferred language
    var language = UserConfig.get_preferred_language()
    if language == "automatic":
        var preferred_language = OS.get_locale_language()
        TranslationServer.set_locale(preferred_language)
    else:
        TranslationServer.set_locale(language)
