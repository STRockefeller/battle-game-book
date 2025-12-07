# CharacterSelection.gd
extends Control

# UI 節點參考
@onready var left_character_container = $MainContainer/LeftPanel/LeftCharacterContainer
@onready var right_character_container = $MainContainer/RightPanel/RightCharacterContainer
@onready var ai_behavior_container = $MainContainer/RightPanel/AIBehaviorContainer
@onready var confirm_button = $MainContainer/CenterPanel/ConfirmButton
@onready var back_button = $MainContainer/CenterPanel/BackButton

# 選擇狀態
var selected_player_character: Character = null
var selected_enemy_character: Character = null
var selected_ai_behavior: String = "random"  # 預設 AI 行為

# 可用的角色資源路徑（動態生成）
var character_resources: Array[String] = []

# 可用的 AI 行為（從工廠獲取）
var ai_behaviors: Array[Dictionary] = []

func _ready():
	_scan_character_resources()
	_load_characters()
	_load_ai_behaviors()
	_setup_ai_selection()
	confirm_button.disabled = true

## 動態掃描角色資源目錄
func _scan_character_resources() -> void:
	var char_dir = "res://resources/characters/"
	var dir = DirAccess.open(char_dir)
	
	if dir == null:
		push_error("無法打開目錄: " + char_dir)
		return
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		# 只加載 .tres 檔案
		if file_name.ends_with(".tres") and not file_name.ends_with(".uid"):
			var full_path = char_dir + file_name
			var resource = load(full_path)
			
			# 檢查是否是 Character 類型
			if resource is Character:
				character_resources.append(full_path)
				print("加載角色資源: " + full_path)
			else:
				print("跳過非角色資源: " + full_path)
		
		file_name = dir.get_next()
	
	if character_resources.is_empty():
		push_warning("未找到任何角色資源")

## 加載所有可用的角色
func _load_characters():
	# 左側：玩家角色選擇
	for char_path in character_resources:
		var character = load(char_path)
		if character:
			var btn = _create_character_button(character, true)
			left_character_container.add_child(btn)
	
	# 右側：敵方角色選擇
	for char_path in character_resources:
		var character = load(char_path)
		if character:
			var btn = _create_character_button(character, false)
			right_character_container.add_child(btn)

## 創建角色選擇按鈕
func _create_character_button(character: Character, is_player: bool) -> Button:
	var btn = Button.new()
	btn.text = character.name
	btn.custom_minimum_size = Vector2(200, 60)
	
	btn.connect("pressed", Callable(self, "_on_character_selected").bind(character, is_player))
	
	return btn

## 從 AIFactory 加載可用的 AI 類型
func _load_ai_behaviors():
	ai_behaviors = AIFactory.get_available_ai_types()
	print("[CharacterSelection] 已加載 %d 種 AI 類型" % ai_behaviors.size())

## 設置 AI 行為選擇
func _setup_ai_selection():
	for ai_info in ai_behaviors:
		var btn = Button.new()
		btn.text = "%s\n%s" % [ai_info["name"], ai_info["description"]]
		btn.custom_minimum_size = Vector2(200, 70)
		btn.toggle_mode = true
		
		if ai_info["id"] == selected_ai_behavior:
			btn.button_pressed = true
		
		btn.connect("pressed", Callable(self, "_on_ai_behavior_selected").bind(ai_info["id"]))
		ai_behavior_container.add_child(btn)

## 角色選擇回調
func _on_character_selected(character: Character, is_player: bool):
	var container = left_character_container if is_player else right_character_container
	
	# 取消之前選擇的按鈕的按下狀態
	for child in container.get_children():
		if child is Button:
			child.button_pressed = false
	
	# 設置新選擇
	if is_player:
		selected_player_character = character.duplicate()
		# 尋找並更新按鈕的按下狀態
		for child in container.get_children():
			if child is Button and child.text == character.name:
				child.button_pressed = true
	else:
		selected_enemy_character = character.duplicate()
		for child in container.get_children():
			if child is Button and child.text == character.name:
				child.button_pressed = true
	
	_update_confirm_button()

## AI 行為選擇回調
func _on_ai_behavior_selected(behavior: String):
	selected_ai_behavior = behavior
	
	# 更新所有 AI 行為按鈕的狀態
	for child in ai_behavior_container.get_children():
		if child is Button:
			child.button_pressed = false
	
	# 找到對應的按鈕並設置為按下
	for child in ai_behavior_container.get_children():
		if child is Button:
			match behavior:
				"random":
					if child.text == "隨機選擇":
						child.button_pressed = true

## 更新確認按鈕狀態
func _update_confirm_button():
	confirm_button.disabled = (selected_player_character == null or selected_enemy_character == null)

## 開始對戰
func _on_confirm_pressed():
	if selected_player_character == null or selected_enemy_character == null:
		return
	
	# 將選擇保存到全局配置
	BattleConfig.set_battle_config(
		selected_player_character,
		selected_enemy_character,
		selected_ai_behavior
	)
	
	# 切換到戰鬥場景
	get_tree().change_scene_to_file("res://scenes/BattleUI.tscn")

## 返回主選單
func _on_back_pressed():
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
