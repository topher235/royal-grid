extends Node

# TODO: change 'res:' to 'user:'
const SETTINGS_CONFIG_FILE = "res://user-settings.cfg"

const SOUND = "sound"
const MUSIC = "music"

var default_user_settings = {
    SOUND: true,
    MUSIC: true,
}
var setting_names = [
    SOUND,
    MUSIC,
]
var current_user_settings = {}


func _ready() -> void:
    load_settings_file()


func load() -> void:
    load_settings_file()


func load_settings_file() -> void:
    var config = ConfigFile.new()
    var err = config.load(SETTINGS_CONFIG_FILE)
    if err != OK:
        pass
    
    for setting_name in setting_names:
        current_user_settings[setting_name] = config.get_value(
            "settings", setting_name, default_user_settings[setting_name]
        )


func save_user_settings() -> void:
    var config = ConfigFile.new()
    for setting_name in setting_names:
        config.set_value(
            "settings", setting_name, current_user_settings[setting_name]
        )
    config.save(SETTINGS_CONFIG_FILE)


func set_setting(setting_name: String, value: Variant) -> void:
    current_user_settings[setting_name] = value


func get_setting(setting_name: String) -> Variant:
    return current_user_settings.get(setting_name, default_user_settings[setting_name])
