extends Control

enum Phase { PLAYER_SELECT, ENEMY_SELECT, CONFIRM }

@onready var top_panel: CharacterDisplayPanel = $VBoxContainer/TopPanel
@onready var bottom_panel: CharacterDisplayPanel = $VBoxContainer/BottomPanel
@onready var carousel: CharacterCarousel = $CenterOverlay/CharacterCarousel
@onready var instruction_label: Label = $InstructionLabel
@onready var ai_hint_label: Label = $CenterOverlay/AIHint
var passive_panel_scene: PackedScene = load("res://scenes/character_selection/components/PassiveSelectionPanel.tscn")
var passive_panel

# 選擇狀態
var selected_player_character: Character = null
var selected_enemy_character: Character = null
var selected_ai_behavior: String = "random"
var player_passive_traits: Array[String] = []
var enemy_passive_traits: Array[String] = []

# 資源快取
var character_resources: Array[String] = []
var characters: Array[Character] = []
var ai_behaviors: Array[Dictionary] = []

var phase: Phase = Phase.PLAYER_SELECT
var _is_transitioning: bool = false

func _ready() -> void:
	_apply_translations()
	_scan_character_resources()
	_load_characters()
	_load_ai_behaviors()
	_setup_carousel()
	top_panel.clear()
	bottom_panel.clear()
	_update_ai_hint()
	_update_instructions()

func _unhandled_input(event: InputEvent) -> void:
	if _is_transitioning:
		return

	if event is InputEventKey and event.pressed and not event.echo:
		var key_event: InputEventKey = event
		if carousel.is_animating():
			if key_event.keycode not in [KEY_ESCAPE, KEY_BACKSPACE]:
				return
		match key_event.keycode:
			KEY_LEFT:
				carousel.move_left()
			KEY_RIGHT:
				carousel.move_right()
			KEY_ENTER, KEY_KP_ENTER, KEY_SPACE:
				_confirm_current_selection()
			KEY_ESCAPE, KEY_BACKSPACE:
				_handle_back()
			KEY_TAB:
				if phase == Phase.ENEMY_SELECT:
					_cycle_ai_behavior()

func _apply_translations() -> void:
	top_panel.set_title(tr("character_selection.player_label"))
	bottom_panel.set_title(tr("character_selection.enemy_section"))

func _scan_character_resources() -> void:
	var char_dir = "res://resources/characters/"
	var dir = DirAccess.open(char_dir)
	if dir == null:
		push_error("無法打開目錄: " + char_dir)
		return

	character_resources.clear()
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if file_name.ends_with(".tres") and not file_name.ends_with(".uid") and not file_name.contains("Assets") and not file_name.contains("Story"):
			var full_path = char_dir + file_name
			var resource = load(full_path)
			if resource is Character:
				character_resources.append(full_path)
			else:
				print("跳過非角色資源: " + full_path)
		file_name = dir.get_next()

func _load_characters() -> void:
	characters.clear()
	for char_path in character_resources:
		var character: Character = load(char_path)
		if character:
			characters.append(character)

func _load_ai_behaviors() -> void:
	ai_behaviors = AIFactory.get_available_ai_types()

func _setup_carousel() -> void:
	if characters.is_empty():
		push_warning("未找到任何角色資源")
		return
	carousel.selection_changed.connect(_on_carousel_selection_changed)
	carousel.set_characters(characters)

func _on_carousel_selection_changed(_character: Character) -> void:
	if phase == Phase.CONFIRM:
		return
	_update_instructions()

func _confirm_current_selection() -> void:
	if carousel.is_animating():
		return
	var current_char := carousel.get_current_character()
	if current_char == null:
		return

	match phase:
		Phase.PLAYER_SELECT:
			selected_player_character = current_char.duplicate()
			top_panel.set_character(selected_player_character)
			# 打開被動特質選擇面板
			_show_passive_selection()
		Phase.ENEMY_SELECT:
			selected_enemy_character = current_char.duplicate()
			bottom_panel.set_character(selected_enemy_character)
			phase = Phase.CONFIRM
			_update_instructions()
			_start_battle_transition()

func _handle_back() -> void:
	match phase:
		Phase.PLAYER_SELECT:
			get_tree().change_scene_to_file("res://scenes/main_menu/MainMenu.tscn")
		Phase.ENEMY_SELECT:
			selected_player_character = null
			top_panel.clear()
			bottom_panel.clear()
			phase = Phase.PLAYER_SELECT
			_update_ai_hint()
			_update_instructions()
		Phase.CONFIRM:
			phase = Phase.ENEMY_SELECT
			selected_enemy_character = null
			bottom_panel.clear()
			_update_ai_hint()
			_update_instructions()

func _cycle_ai_behavior() -> void:
	if ai_behaviors.is_empty():
		return
	var current_index := 0
	for i in range(ai_behaviors.size()):
		if ai_behaviors[i].get("id", "") == selected_ai_behavior:
			current_index = i
			break
	selected_ai_behavior = ai_behaviors[(current_index + 1) % ai_behaviors.size()].get("id", selected_ai_behavior)
	_update_ai_hint()

func _show_passive_selection() -> void:
	if passive_panel:
		passive_panel.queue_free()
	passive_panel = passive_panel_scene.instantiate()
	add_child(passive_panel)
	passive_panel.setup(2)
	passive_panel.confirmed.connect(func(ids: Array[String]):
		player_passive_traits = ids
		# 關閉面板並進入對手選擇
		passive_panel.queue_free()
		phase = Phase.ENEMY_SELECT
		bottom_panel.clear()
		_update_ai_hint()
		_update_instructions()
	)
	passive_panel.canceled.connect(func():
		# 若取消，回到玩家選擇
		passive_panel.queue_free()
		selected_player_character = null
		top_panel.clear()
		phase = Phase.PLAYER_SELECT
		_update_ai_hint()
		_update_instructions()
	)

func _pick_enemy_passives_random(count: int = 2) -> Array[String]:
	var all_traits = PassiveTraitLibrary.get_all_traits()
	var pool: Array[String] = []
	for t in all_traits:
		pool.append(t.id)
	pool.shuffle()
	return pool.slice(0, min(count, pool.size()))

func _update_ai_hint() -> void:
	if phase != Phase.ENEMY_SELECT:
		ai_hint_label.visible = false
		return

	ai_hint_label.visible = true
	var ai_info := _get_ai_info(selected_ai_behavior)
	var ai_name := selected_ai_behavior
	if not ai_info.is_empty():
		ai_name = _with_fallback(tr(ai_info.get("name_key", ai_name)), ai_name)
	ai_hint_label.text = "%s: %s" % [tr("character_selection.ai_label"), ai_name]

func _get_ai_info(ai_id: String) -> Dictionary:
	for info in ai_behaviors:
		if info.get("id", "") == ai_id:
			return info
	return {}

func _update_instructions() -> void:
	match phase:
		Phase.PLAYER_SELECT:
			instruction_label.text = _with_fallback(
				tr("character_selection.hint_player"),
				"玩家：←/→ 切換  Enter/Space 確認  Esc 返回"
			)
		Phase.ENEMY_SELECT:
			instruction_label.text = _with_fallback(
				tr("character_selection.hint_enemy"),
				"對手：←/→ 切換  Enter/Space 確認  Tab 切換AI  Esc 返回"
			)
		Phase.CONFIRM:
			instruction_label.text = _with_fallback(
				tr("character_selection.starting"),
				"正在開始戰鬥..."
			)

func _with_fallback(text: String, fallback: String) -> String:
	return fallback if text == "" or text.begins_with("character_selection.") else text

func _start_battle_transition() -> void:
	if _is_transitioning:
		return
	if selected_player_character == null or selected_enemy_character == null:
		return
	_is_transitioning = true
	# 若敵方未指定被動，隨機選擇
	if enemy_passive_traits.is_empty():
		enemy_passive_traits = _pick_enemy_passives_random(2)
	BattleConfig.set_battle_config(
		selected_player_character,
		selected_enemy_character,
		selected_ai_behavior,
		player_passive_traits,
		enemy_passive_traits
	)
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.35).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.finished.connect(_go_to_battle)

func _go_to_battle() -> void:
	get_tree().change_scene_to_file("res://scenes/battle/BattleUI.tscn")
