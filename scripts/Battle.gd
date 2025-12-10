extends Control

const P1_COLOR := "#4fb1ff"
const P2_COLOR := "#ff8b5c"
const SYSTEM_COLOR := "yellow"

@onready var battle_manager: BattleManager = $BattleManager

# 視覺播放系統
var visual_player: BattleVisualPlayer = null
var asset_manager: AssetManager = null
var p1_visual_state = null
var p2_visual_state = null

# 角色精靈節點（需要在場景中手動添加或動態創建）
var p1_sprite: Sprite2D = null
var p2_sprite: Sprite2D = null

# 玩家 1 UI 節點
@onready var p1_name_label = $MainContainer/CharacterStatusPanel/Player1Panel/MarginContainer/VBoxContainer/NameLabel
@onready var p1_hp_label = $MainContainer/CharacterStatusPanel/Player1Panel/MarginContainer/VBoxContainer/HpLabel
@onready var p1_mp_label = $MainContainer/CharacterStatusPanel/Player1Panel/MarginContainer/VBoxContainer/MpLabel
@onready var p1_sta_label = $MainContainer/CharacterStatusPanel/Player1Panel/MarginContainer/VBoxContainer/StaLabel
@onready var p1_stance_label = $MainContainer/CharacterStatusPanel/Player1Panel/MarginContainer/VBoxContainer/StanceLabel

# 玩家 2 UI 節點
@onready var p2_name_label = $MainContainer/CharacterStatusPanel/Player2Panel/MarginContainer/VBoxContainer/NameLabel
@onready var p2_hp_label = $MainContainer/CharacterStatusPanel/Player2Panel/MarginContainer/VBoxContainer/HpLabel
@onready var p2_mp_label = $MainContainer/CharacterStatusPanel/Player2Panel/MarginContainer/VBoxContainer/MpLabel
@onready var p2_sta_label = $MainContainer/CharacterStatusPanel/Player2Panel/MarginContainer/VBoxContainer/StaLabel
@onready var p2_stance_label = $MainContainer/CharacterStatusPanel/Player2Panel/MarginContainer/VBoxContainer/StanceLabel

# 戰鬥日誌和操作面板
@onready var log_content = $MainContainer/BottomContainer/LogBox/MarginContainer/LogContent
@onready var instruction_label = $MainContainer/BottomContainer/ActionPanel/MarginContainer/VBoxContainer/InstructionLabel
@onready var moves_container = $MainContainer/BottomContainer/ActionPanel/MarginContainer/VBoxContainer/MovesContainer
@onready var battle_area_placeholder = $MainContainer/CenterContainer/BattleAreaPlaceholder

# 戰鬥狀態
var battle_finished: bool = false

func _ready():
	_apply_translations()
	# 初始化資源管理系統
	_initialize_visual_system()
	
	# 連接 BattleManager 信號
	battle_manager.connect("turn_start_selection", Callable(self, "_on_turn_start_selection"))
	battle_manager.connect("all_actions_selected", Callable(self, "_on_all_actions_selected"))
	battle_manager.connect("action_executed", Callable(self, "_on_action_executed"))
	battle_manager.connect("turn_ended", Callable(self, "_on_turn_ended"))
	battle_manager.connect("battle_ended", Callable(self, "_on_battle_ended"))
	
	# 初始化 UI
	update_all_status()
	_apply_status_colors()
	
	# 開始戰鬥
	battle_manager.start_battle()

func _apply_translations() -> void:
	instruction_label.text = tr("battle.action.instruction")
	if battle_area_placeholder:
		battle_area_placeholder.text = tr("battle.placeholder_arena")

## 初始化視覺系統
func _initialize_visual_system() -> void:
	# 建立AssetManager
	asset_manager = AssetManager.get_instance()
	if not asset_manager.is_inside_tree():
		get_tree().root.add_child(asset_manager)
	
	# 建立BattleVisualPlayer
	visual_player = BattleVisualPlayer.new()
	visual_player.name = "BattleVisualPlayer"
	add_child(visual_player)
	
	# 初始化角色視覺狀態
	if battle_manager.player1:
		p1_visual_state = CharacterVisualState.new(battle_manager.player1.name)
		p1_visual_state.update_hp(battle_manager.get_current_hp(battle_manager.player1), battle_manager.player1.max_hp)
	
	if battle_manager.player2:
		p2_visual_state = CharacterVisualState.new(battle_manager.player2.name)
		p2_visual_state.update_hp(battle_manager.get_current_hp(battle_manager.player2), battle_manager.player2.max_hp)
	
	# 創建角色精靈節點
	_create_character_sprites()

## 創建角色精靈節點
func _create_character_sprites() -> void:
	# 玩家1精靈（左側）
	p1_sprite = Sprite2D.new()
	p1_sprite.name = "Player1Sprite"
	p1_sprite.position = Vector2(200, 300)
	p1_sprite.scale = Vector2(2.0, 2.0)
	add_child(p1_sprite)
	
	# 玩家2精靈（右側）
	p2_sprite = Sprite2D.new()
	p2_sprite.name = "Player2Sprite"
	p2_sprite.position = Vector2(800, 300)
	p2_sprite.scale = Vector2(2.0, 2.0)
	p2_sprite.flip_h = true  # 翻轉面向玩家1
	add_child(p2_sprite)
	
	# 載入初始精靈圖
	_update_character_sprites()

## 更新所有角色狀態顯示
func update_all_status():
	update_character_status(battle_manager.player1, true)
	update_character_status(battle_manager.player2, false)

## 更新單個角色的狀態顯示
func update_character_status(character: Character, is_player1: bool):
	var name_label = p1_name_label if is_player1 else p2_name_label
	var hp_label = p1_hp_label if is_player1 else p2_hp_label
	var mp_label = p1_mp_label if is_player1 else p2_mp_label
	var sta_label = p1_sta_label if is_player1 else p2_sta_label
	var stance_label = p1_stance_label if is_player1 else p2_stance_label
	
	# 從後端數據更新 UI（從 BattleManager 獲取暫時值）
	name_label.text = character.name
	var current_hp = battle_manager.get_current_hp(character)
	hp_label.text = tr("battle.status.hp").format({"current": current_hp, "max": character.max_hp})
	mp_label.text = tr("battle.status.mp").format({"current": battle_manager.get_current_mp(character), "max": character.max_mp})
	sta_label.text = tr("battle.status.sta").format({"current": battle_manager.get_current_sta(character), "max": character.max_sta})
	
	# 從 stance_manager 取得當前姿態
	var stance_name = tr("battle.stance.default")
	if character.stance_manager:
		stance_name = character.stance_manager.get_current_stance_name()
	
	stance_label.text = tr("battle.status.stance").format({"stance": stance_name})
	
	# 更新視覺狀態
	if is_player1 and p1_visual_state:
		p1_visual_state.update_hp(current_hp, character.max_hp)
	elif not is_player1 and p2_visual_state:
		p2_visual_state.update_hp(current_hp, character.max_hp)

## 更新角色精靈圖
func _update_character_sprites() -> void:
	if p1_visual_state and p1_sprite and battle_manager.player1 and battle_manager.player1.character_assets:
		visual_player.play_idle(p1_sprite, p1_visual_state, battle_manager.player1.character_assets)
	
	if p2_visual_state and p2_sprite and battle_manager.player2 and battle_manager.player2.character_assets:
		visual_player.play_idle(p2_sprite, p2_visual_state, battle_manager.player2.character_assets)

func _apply_status_colors() -> void:
	var p1_labels = [p1_name_label, p1_hp_label, p1_mp_label, p1_sta_label, p1_stance_label]
	for label in p1_labels:
		label.add_theme_color_override("font_color", Color(P1_COLOR))
	var p2_labels = [p2_name_label, p2_hp_label, p2_mp_label, p2_sta_label, p2_stance_label]
	for label in p2_labels:
		label.add_theme_color_override("font_color", Color(P2_COLOR))

func _color_for_character(character: Character) -> String:
	return P1_COLOR if character == battle_manager.player1 else P2_COLOR

## 新增訊息到戰鬥日誌
func add_log_entry(message: String, color: String = "white"):
	var formatted_message = "[color=%s]%s[/color]" % [color, message]
	log_content.append_text(formatted_message + "\n")

func _on_turn_start_selection(player1: Character, _player2: Character):
	update_all_status()
	
	# 清空之前的行動按鈕
	for child in moves_container.get_children():
		child.queue_free()
	
	# 更新提示文本
	instruction_label.text = tr("battle.action.prompt").format({"turn": battle_manager.state.turn})
	
	# 顯示玩家 1 的可用動作按鈕
	var available_actions = battle_manager._get_available_actions(player1)
	
	for action in available_actions:
		var btn = Button.new()
		var state = battle_manager.get_action_state(player1, action)
		var cooldown_text = ""
		if state["cooldown"] > 0:
			cooldown_text = tr("battle.action.cooldown").format({"turns": state["cooldown"]})
		var insufficient_text = ""
		if state["insufficient"]:
			insufficient_text = tr("battle.action.insufficient")
		btn.text = tr("battle.action.button").format({
			"name": action.name,
			"mp": action.cost_mp,
			"sta": action.cost_stamina,
			"cooldown": cooldown_text,
			"insufficient": insufficient_text
		})
		btn.disabled = state["disabled"]
		btn.tooltip_text = tr("battle.action.tooltip").format({
			"current_mp": state["current_mp"],
			"max_mp": player1.max_mp,
			"current_sta": state["current_sta"],
			"max_sta": player1.max_sta
		})
		btn.connect("pressed", Callable(self, "_on_action_selected").bind(action))
		moves_container.add_child(btn)
	
	# 記錄日誌
	add_log_entry(tr("battle.log.turn_start").format({"turn": battle_manager.state.turn}), SYSTEM_COLOR)

## 玩家選擇了動作
func _on_action_selected(action: Action):
	battle_manager.player_select_action(action)
	
	# 清空按鈕（等待動作解析）
	for child in moves_container.get_children():
		child.queue_free()
	
	instruction_label.text = tr("battle.waiting_choices")

## 所有選擇都完成 - 動作即將執行
func _on_all_actions_selected():
	add_log_entry(tr("battle.all_actions_selected"), SYSTEM_COLOR)

## 動作執行
func _on_action_executed(user: Character, target: Character, action: Action, result: Dictionary):
	var log_message = tr("battle.action.use").format({"user": user.name, "action": action.name})
	var color = _color_for_character(user)
	
	# 播放動作動畫
	var is_user_p1 = (user == battle_manager.player1)
	var is_target_p1 = (target == battle_manager.player1)
	
	var user_sprite = p1_sprite if is_user_p1 else p2_sprite
	var target_sprite = p1_sprite if is_target_p1 else p2_sprite
	var user_visual_state = p1_visual_state if is_user_p1 else p2_visual_state
	var target_visual_state = p1_visual_state if is_target_p1 else p2_visual_state
	
	# 設定使用者為攻擊姿態
	if user_visual_state:
		user_visual_state.set_pose(CharacterVisualState.Pose.ATTACK)
	
	# 播放動作動畫（傳遞ActionAssets和CharacterAssets）
	if visual_player and user_sprite and user_visual_state and action.action_assets and user.character_assets:
		visual_player.play_action_sequence(user_sprite, user_visual_state, action.action_assets, user.character_assets)
	
	if result["hit"]:
		log_message += tr("battle.action.hit").format({"damage": result["actual_damage"]})
		
		# 播放受擊效果
		if visual_player and target_sprite and target_visual_state and action.action_assets and target.character_assets:
			# 等待動作動畫完成後播放受擊
			var action_duration = action.action_assets.animation_duration if action.action_assets else 1.0
			await get_tree().create_timer(action_duration * 0.7).timeout
			visual_player.play_hit_sequence(target_sprite, target_visual_state, target.character_assets, action.action_assets.vfx_hit, 0.3)
		
		if result["status_applied"]:
			log_message += tr("battle.action.status_applied").format({"status": result["status_applied"]})
		
		if result["stance_changed"]:
			log_message += tr("battle.action.stance_changed")
	else:
		log_message += tr("battle.action.miss")
	
	add_log_entry(log_message, color)
	update_all_status()
	
	# 動畫完成後恢復待機姿態
	if visual_player:
		await visual_player.animation_finished
		_update_character_sprites()

## 回合結束
func _on_turn_ended():
	add_log_entry(tr("battle.log.turn_end"), SYSTEM_COLOR)

## 戰鬥結束
func _on_battle_ended(winner: Character):
	battle_finished = true
	
	# 清空按鈕
	for child in moves_container.get_children():
		child.queue_free()
	
	if winner:
		instruction_label.text = tr("battle.end.win_instruction").format({"winner": winner.name})
		add_log_entry(tr("battle.end.win_log").format({"winner": winner.name}), "gold")
		
		# 播放勝利/失敗動畫
		var is_winner_p1 = (winner == battle_manager.player1)
		var winner_sprite = p1_sprite if is_winner_p1 else p2_sprite
		var loser_sprite = p2_sprite if is_winner_p1 else p1_sprite
		var winner_visual_state = p1_visual_state if is_winner_p1 else p2_visual_state
		var loser_visual_state = p2_visual_state if is_winner_p1 else p1_visual_state
		var loser = battle_manager.player2 if is_winner_p1 else battle_manager.player1
		
		if visual_player:
			if winner_visual_state and winner.character_assets:
				visual_player.play_victory(winner_sprite, winner_visual_state, winner.character_assets)
			if loser_visual_state and loser and loser.character_assets:
				visual_player.play_defeat(loser_sprite, loser_visual_state, loser.character_assets)
	else:
		instruction_label.text = tr("battle.end.draw_instruction")
		add_log_entry(tr("battle.end.draw_log"), "gold")

func _input(event: InputEvent):
	if battle_finished and event is InputEventKey and event.pressed:
		get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
