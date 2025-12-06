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

func _ready():
	# 連接 BattleManager 信號
	battle_manager.connect("turn_started", Callable(self, "_on_turn_started"))
	battle_manager.connect("action_resolved", Callable(self, "_on_action_resolved"))
	battle_manager.connect("battle_ended", Callable(self, "_on_battle_ended"))
	
	# 初始化 UI
	update_all_status()

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

func _on_turn_started(active_character: Character):
	update_all_status()
	
	# 清空之前的行動按鈕
	for child in moves_container.get_children():
		child.queue_free()
	
	# 更新提示文本
	instruction_label.text = "%s 的回合，請選擇動作：" % active_character.name

	# 如果是玩家 1，顯示操作選單
	if active_character == battle_manager.player1:
		for action in active_character.available_moves:
			var btn = Button.new()
			btn.text = action.name
			btn.connect("pressed", Callable(self, "_on_action_selected").bind(action))
			moves_container.add_child(btn)
	else:
		# AI 控制玩家 2 - 選擇第一個可用的動作
		if active_character.available_moves.size() > 0:
			var action = active_character.available_moves[0]
			battle_manager.execute_action(active_character, battle_manager.player1, action)

func _on_action_selected(action: Action):
	battle_manager.execute_action(battle_manager.player1, battle_manager.player2, action)
	
	# 清空按鈕
	for child in moves_container.get_children():
		child.queue_free()

func _on_action_resolved(user: Character, target: Character, action: Action, log: String):
	add_log_entry(log)
	update_all_status()

func _on_battle_ended(winner: Character):
	instruction_label.text = "戰鬥結束！勝利者是 %s" % winner.name
	for child in moves_container.get_children():
		child.queue_free()
