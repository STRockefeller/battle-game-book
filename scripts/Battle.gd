extends Control

@onready var battle_manager: BattleManager = $BattleManager

# 玩家 1 UI 節點
@onready var p1_name_label = $MainContainer/CharacterStatusPanel/Player1Panel/MarginContainer/VBoxContainer/NameLabel
@onready var p1_hp_label = $MainContainer/CharacterStatusPanel/Player1Panel/MarginContainer/VBoxContainer/HpLabel
@onready var p1_mp_label = $MainContainer/CharacterStatusPanel/Player1Panel/MarginContainer/VBoxContainer/MpLabel
@onready var p1_stance_label = $MainContainer/CharacterStatusPanel/Player1Panel/MarginContainer/VBoxContainer/StanceLabel

# 玩家 2 UI 節點
@onready var p2_name_label = $MainContainer/CharacterStatusPanel/Player2Panel/MarginContainer/VBoxContainer/NameLabel
@onready var p2_hp_label = $MainContainer/CharacterStatusPanel/Player2Panel/MarginContainer/VBoxContainer/HpLabel
@onready var p2_mp_label = $MainContainer/CharacterStatusPanel/Player2Panel/MarginContainer/VBoxContainer/MpLabel
@onready var p2_stance_label = $MainContainer/CharacterStatusPanel/Player2Panel/MarginContainer/VBoxContainer/StanceLabel

# 戰鬥日誌和操作面板
@onready var log_content = $MainContainer/BottomContainer/LogBox/MarginContainer/LogContent
@onready var instruction_label = $MainContainer/BottomContainer/ActionPanel/MarginContainer/VBoxContainer/InstructionLabel
@onready var moves_container = $MainContainer/BottomContainer/ActionPanel/MarginContainer/VBoxContainer/MovesContainer

# 戰鬥狀態
var battle_finished: bool = false

func _ready():
	# 連接 BattleManager 信號
	battle_manager.connect("turn_start_selection", Callable(self, "_on_turn_start_selection"))
	battle_manager.connect("all_actions_selected", Callable(self, "_on_all_actions_selected"))
	battle_manager.connect("action_executed", Callable(self, "_on_action_executed"))
	battle_manager.connect("turn_ended", Callable(self, "_on_turn_ended"))
	battle_manager.connect("battle_ended", Callable(self, "_on_battle_ended"))
	
	# 初始化 UI
	update_all_status()
	
	# 開始戰鬥
	battle_manager.start_battle()

## 更新所有角色狀態顯示
func update_all_status():
	update_character_status(battle_manager.player1, true)
	update_character_status(battle_manager.player2, false)

## 更新單個角色的狀態顯示
func update_character_status(character: Character, is_player1: bool):
	var name_label = p1_name_label if is_player1 else p2_name_label
	var hp_label = p1_hp_label if is_player1 else p2_hp_label
	var mp_label = p1_mp_label if is_player1 else p2_mp_label
	var stance_label = p1_stance_label if is_player1 else p2_stance_label
	
	# 從後端數據更新 UI（使用 BattleManager 或直接從 Character）
	name_label.text = character.name
	hp_label.text = "HP: %d / %d" % [character.current_hp, character.max_hp]
	mp_label.text = "MP: %d / %d" % [character.current_mp, character.max_mp]
	
	# 從 stance_manager 取得當前姿態
	var stance_name = "站立"  # 預設值
	if character.stance_manager and character.stance_manager.current_stance:
		match character.stance_manager.current_stance.type:
			Stance.Type.STANDING:
				stance_name = "站立"
			Stance.Type.KNOCKED_DOWN:
				stance_name = "倒地"
			Stance.Type.AIRBORNE:
				stance_name = "滯空"
			Stance.Type.GUARDING:
				stance_name = "防禦"
	
	stance_label.text = "姿態: %s" % stance_name

## 新增訊息到戰鬥日誌
func add_log_entry(message: String, color: String = "white"):
	var formatted_message = "[color=%s]%s[/color]" % [color, message]
	log_content.append_text(formatted_message + "\n")

func _on_turn_start_selection(player1: Character, player2: Character):
	update_all_status()
	
	# 清空之前的行動按鈕
	for child in moves_container.get_children():
		child.queue_free()
	
	# 更新提示文本
	instruction_label.text = "請選擇行動 (第 %d 回合)" % battle_manager.current_turn
	
	# 顯示玩家 1 的可用動作按鈕
	var available_actions = battle_manager._get_available_actions(player1)
	
	for action in available_actions:
		var btn = Button.new()
		btn.text = "%s (MP: %d, STA: %d)" % [action.name, action.cost_mp, action.stamina_cost]
		btn.connect("pressed", Callable(self, "_on_action_selected").bind(action))
		moves_container.add_child(btn)
	
	# 記錄日誌
	add_log_entry("第 %d 回合開始" % battle_manager.current_turn, "yellow")

## 玩家選擇了動作
func _on_action_selected(action: Action):
	battle_manager.player_select_action(action)
	
	# 清空按鈕（等待動作解析）
	for child in moves_container.get_children():
		child.queue_free()
	
	instruction_label.text = "等待所有選擇完成..."

## 所有選擇都完成 - 動作即將執行
func _on_all_actions_selected():
	add_log_entry("所有選擇完成，動作執行中...", "cyan")

## 動作執行
func _on_action_executed(user: Character, target: Character, action: Action, result: Dictionary):
	var log_message = "%s 使用了 %s" % [user.name, action.name]
	var color = "white"
	
	if result["hit"]:
		log_message += "！命中！造成 %d 傷害" % result["actual_damage"]
		color = "red"
		
		if result["status_applied"]:
			log_message += "，施加了 %s" % result["status_applied"]
		
		if result["stance_changed"]:
			log_message += "，改變了姿態"
	else:
		log_message += "，但沒有命中！"
		color = "gray"
	
	add_log_entry(log_message, color)
	update_all_status()

## 回合結束
func _on_turn_ended():
	add_log_entry("回合結束", "yellow")

## 戰鬥結束
func _on_battle_ended(winner: Character):
	battle_finished = true
	
	# 清空按鈕
	for child in moves_container.get_children():
		child.queue_free()
	
	if winner:
		instruction_label.text = "戰鬥結束！勝利者是 %s！按任意鍵返回主選單..." % winner.name
		add_log_entry("戰鬥結束！勝利者是 %s！" % winner.name, "gold")
	else:
		instruction_label.text = "戰鬥結束！平局。按任意鍵返回主選單..."
		add_log_entry("戰鬥結束！平局", "gold")

func _input(event: InputEvent):
	if battle_finished and event is InputEventKey and event.pressed:
		get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
