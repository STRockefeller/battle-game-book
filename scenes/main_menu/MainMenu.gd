# MainMenu.gd
extends Control

const GAME_VERSION := "0.1.0"

@onready var title_label: Label = $MainContainer/TitleContainer/TitleLabel
@onready var subtitle_label: Label = $MainContainer/TitleContainer/SubtitleLabel
@onready var new_game_button: Button = $MainContainer/ButtonContainer/NewGameButton
@onready var test_battle_button: Button = $MainContainer/ButtonContainer/TestBattleButton
@onready var test_story_button: Button = $MainContainer/ButtonContainer/TestStoryButton
@onready var settings_button: Button = $MainContainer/ButtonContainer/SettingsButton
@onready var credits_button: Button = $MainContainer/ButtonContainer/CreditsButton
@onready var exit_button: Button = $MainContainer/ButtonContainer/ExitButton
@onready var version_label: Label = $MainContainer/VersionLabel

func _ready():
	_apply_translations()

func _apply_translations():
	title_label.text = tr("main_menu.title")
	subtitle_label.text = tr("main_menu.subtitle")
	new_game_button.text = tr("main_menu.new_game")
	test_battle_button.text = tr("main_menu.test_battle")
	if test_story_button:  # Only set if button exists in scene
		test_story_button.text = "Test Story Mode"  # Temporary, add to translation later
	settings_button.text = tr("main_menu.settings")
	credits_button.text = tr("main_menu.credits")
	exit_button.text = tr("main_menu.exit")
	version_label.text = tr("main_menu.version").format({"version": GAME_VERSION})

func _on_new_game_pressed():
	print("開始遊戲 - 功能待實現")

func _on_test_battle_pressed():
	# 切換到角色選擇場景
	get_tree().change_scene_to_file("res://scenes/character_selection/CharacterSelection.tscn")

func _on_test_story_pressed():
	# 切換到故事模式測試場景
	get_tree().change_scene_to_file("res://scenes/StoryModeTest.tscn")

func _on_settings_pressed():
	get_tree().change_scene_to_file("res://scenes/settings/Settings.tscn")

func _on_credits_pressed():
	print("製作人員 - 功能待實現")

func _on_exit_pressed():
	# 退出遊戲
	get_tree().quit()
