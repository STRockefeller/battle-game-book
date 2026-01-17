# Settings.gd
# 設定場景：提供使用者調整全域設定並立即套用
extends Control

const VOLUME_MIN_DB := -40.0
const VOLUME_MAX_DB := 6.0

@onready var title_label: Label = $MainMargin/MainContainer/TitleLabel
@onready var description_label: Label = $MainMargin/MainContainer/DescriptionLabel
@onready var settings_grid: GridContainer = $MainMargin/MainContainer/SettingsGrid
@onready var language_label: Label = $MainMargin/MainContainer/SettingsGrid/LanguageLabel
@onready var language_option: OptionButton = $MainMargin/MainContainer/SettingsGrid/LanguageOption
@onready var fullscreen_label: Label = $MainMargin/MainContainer/SettingsGrid/FullscreenLabel
@onready var fullscreen_check: CheckButton = $MainMargin/MainContainer/SettingsGrid/FullscreenCheck
@onready var master_label: Label = $MainMargin/MainContainer/SettingsGrid/MasterLabel
@onready var master_slider: HSlider = $MainMargin/MainContainer/SettingsGrid/MasterSliderContainer/MasterSlider
@onready var master_value: Label = $MainMargin/MainContainer/SettingsGrid/MasterSliderContainer/MasterValue
@onready var bgm_label: Label = $MainMargin/MainContainer/SettingsGrid/BgmLabel
@onready var bgm_slider: HSlider = $MainMargin/MainContainer/SettingsGrid/BgmSliderContainer/BgmSlider
@onready var bgm_value: Label = $MainMargin/MainContainer/SettingsGrid/BgmSliderContainer/BgmValue
@onready var sfx_label: Label = $MainMargin/MainContainer/SettingsGrid/SfxLabel
@onready var sfx_slider: HSlider = $MainMargin/MainContainer/SettingsGrid/SfxSliderContainer/SfxSlider
@onready var sfx_value: Label = $MainMargin/MainContainer/SettingsGrid/SfxSliderContainer/SfxValue
@onready var status_label: Label = $MainMargin/MainContainer/StatusLabel
@onready var save_button: Button = $MainMargin/MainContainer/ButtonRow/SaveButton
@onready var back_button: Button = $MainMargin/MainContainer/ButtonRow/BackButton

func _ready() -> void:
	Localization.ensure_loaded()
	_apply_translations()
	_configure_sliders()
	_populate_locales()
	_load_settings_into_ui()

func _apply_translations() -> void:
	title_label.text = tr("settings.title")
	description_label.text = tr("settings.subtitle")
	language_label.text = tr("settings.language")
	fullscreen_label.text = tr("settings.fullscreen")
	master_label.text = tr("settings.master_volume")
	bgm_label.text = tr("settings.bgm_volume")
	sfx_label.text = tr("settings.sfx_volume")
	save_button.text = tr("settings.save")
	back_button.text = tr("settings.back")
	status_label.text = ""

func _configure_sliders() -> void:
	for slider in [master_slider, bgm_slider, sfx_slider]:
		slider.min_value = VOLUME_MIN_DB
		slider.max_value = VOLUME_MAX_DB
		slider.step = 0.5

func _populate_locales() -> void:
	language_option.clear()
	var saved_locale := SettingsManager.get_locale()
	var select_index := 0
	for locale in Localization.SUPPORTED_LOCALES:
		var label := _get_locale_label(locale)
		var id := language_option.item_count
		language_option.add_item(label, id)
		language_option.set_item_metadata(id, locale)
		if locale == saved_locale:
			select_index = id
	language_option.select(select_index)

func _load_settings_into_ui() -> void:
	fullscreen_check.button_pressed = SettingsManager.is_fullscreen()
	master_slider.value = SettingsManager.get_master_volume_db()
	bgm_slider.value = SettingsManager.get_bgm_volume_db()
	sfx_slider.value = SettingsManager.get_sfx_volume_db()
	_update_volume_label(master_value, master_slider.value)
	_update_volume_label(bgm_value, bgm_slider.value)
	_update_volume_label(sfx_value, sfx_slider.value)

func _get_locale_label(locale: String) -> String:
	match locale:
		"en":
			return tr("settings.locale.en")
		"zh_TW":
			return tr("settings.locale.zh_tw")
		_:
			return locale

func _on_master_slider_value_changed(value: float) -> void:
	_update_volume_label(master_value, value)

func _on_bgm_slider_value_changed(value: float) -> void:
	_update_volume_label(bgm_value, value)

func _on_sfx_slider_value_changed(value: float) -> void:
	_update_volume_label(sfx_value, value)

func _update_volume_label(label: Label, value: float) -> void:
	label.text = "%0.1f dB" % value

func _on_save_button_pressed() -> void:
	SettingsManager.set_locale(_get_selected_locale())
	SettingsManager.set_fullscreen(fullscreen_check.button_pressed)
	SettingsManager.set_master_volume_db(master_slider.value)
	SettingsManager.set_bgm_volume_db(bgm_slider.value)
	SettingsManager.set_sfx_volume_db(sfx_slider.value)
	SettingsManager.apply_settings()
	SettingsManager.save_settings()
	status_label.text = tr("settings.saved")

func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu/MainMenu.tscn")

func _get_selected_locale() -> String:
	var selected := language_option.get_selected_id()
	var meta: String = language_option.get_item_metadata(selected)
	return meta if meta != null else Localization.DEFAULT_LOCALE
