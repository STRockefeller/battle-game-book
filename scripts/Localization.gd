# Localization.gd
# 全域翻譯管理：載入 .po 檔並設定語系
class_name LocalizationManager
extends Node

const SUPPORTED_LOCALES := ["en", "zh_TW"]
const DEFAULT_LOCALE := "zh_TW"
const TRANSLATION_DIR := "res://i18n"

var _loaded: bool = false

func _ready() -> void:
	_load_translations()
	_set_initial_locale()

func _load_translations() -> void:
	if _loaded:
		return
	var dir := DirAccess.open(TRANSLATION_DIR)
	if dir == null:
		push_warning("找不到翻譯目錄: %s" % TRANSLATION_DIR)
		return
	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(".po"):
			var path := "%s/%s" % [TRANSLATION_DIR, file_name]
			var translation: Translation = load(path)
			if translation:
				TranslationServer.add_translation(translation)
			else:
				push_warning("無法載入翻譯檔: %s" % path)
		file_name = dir.get_next()
	dir.list_dir_end()
	_loaded = true

func _set_initial_locale() -> void:
	var locale := TranslationServer.get_locale()
	if locale not in SUPPORTED_LOCALES:
		locale = DEFAULT_LOCALE
	TranslationServer.set_locale(locale)

func set_locale(locale: String) -> void:
	var normalized := locale if locale in SUPPORTED_LOCALES else DEFAULT_LOCALE
	TranslationServer.set_locale(normalized)

func get_locale() -> String:
	return TranslationServer.get_locale()

func ensure_loaded() -> void:
	_load_translations()
