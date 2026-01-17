# SettingsManager.gd
# 全域設定管理：負責讀寫使用者設定並套用到系統
extends Node

const CONFIG_PATH := "user://settings.cfg"
const CONFIG_SECTION := "settings"
const DEFAULT_SETTINGS := {
	"locale": Localization.DEFAULT_LOCALE,
	"fullscreen": false,
	"master_volume_db": 0.0,
	"bgm_volume_db": -4.0,
	"sfx_volume_db": -4.0,
}

var _settings: Dictionary = {}

func _ready() -> void:
	load_settings()
	apply_settings()

func load_settings() -> void:
	_settings = DEFAULT_SETTINGS.duplicate()
	var config := ConfigFile.new()
	var err := config.load(CONFIG_PATH)
	if err == OK:
		for key in DEFAULT_SETTINGS.keys():
			if config.has_section_key(CONFIG_SECTION, key):
				_settings[key] = config.get_value(CONFIG_SECTION, key, DEFAULT_SETTINGS[key])
	elif err != ERR_DOES_NOT_EXIST:
		push_warning("讀取設定檔失敗: %s" % err)
	# 確保檔案存在
	save_settings()

func save_settings() -> void:
	var config := ConfigFile.new()
	for key in _settings.keys():
		config.set_value(CONFIG_SECTION, key, _settings[key])
	var err := config.save(CONFIG_PATH)
	if err != OK:
		push_warning("儲存設定檔失敗: %s" % err)

func apply_settings() -> void:
	_apply_locale()
	_apply_display()
	_apply_audio()

func _apply_locale() -> void:
	Localization.set_locale(get_locale())

func _apply_display() -> void:
	var fullscreen := is_fullscreen()
	var mode := DisplayServer.WINDOW_MODE_FULLSCREEN if fullscreen else DisplayServer.WINDOW_MODE_WINDOWED
	DisplayServer.window_set_mode(mode)

func _apply_audio() -> void:
	_set_bus_volume("Master", get_master_volume_db())
	_set_bus_volume("BGM", get_bgm_volume_db())
	_set_bus_volume("SFX", get_sfx_volume_db())

func _set_bus_volume(bus_name: String, volume_db: float) -> void:
	var index := AudioServer.get_bus_index(bus_name)
	if index == -1:
		return
	var clamped: float = clamp(volume_db, -80.0, 6.0)
	AudioServer.set_bus_volume_db(index, clamped)

func set_locale(locale: String) -> void:
	var normalized := locale if locale in Localization.SUPPORTED_LOCALES else Localization.DEFAULT_LOCALE
	_settings["locale"] = normalized

func get_locale() -> String:
	return _settings.get("locale", Localization.DEFAULT_LOCALE)

func set_fullscreen(enabled: bool) -> void:
	_settings["fullscreen"] = enabled

func is_fullscreen() -> bool:
	return bool(_settings.get("fullscreen", false))

func set_master_volume_db(volume_db: float) -> void:
	_settings["master_volume_db"] = volume_db

func get_master_volume_db() -> float:
	return float(_settings.get("master_volume_db", DEFAULT_SETTINGS["master_volume_db"]))

func set_bgm_volume_db(volume_db: float) -> void:
	_settings["bgm_volume_db"] = volume_db

func get_bgm_volume_db() -> float:
	return float(_settings.get("bgm_volume_db", DEFAULT_SETTINGS["bgm_volume_db"]))

func set_sfx_volume_db(volume_db: float) -> void:
	_settings["sfx_volume_db"] = volume_db

func get_sfx_volume_db() -> float:
	return float(_settings.get("sfx_volume_db", DEFAULT_SETTINGS["sfx_volume_db"]))

func get_snapshot() -> Dictionary:
	return _settings.duplicate(true)
