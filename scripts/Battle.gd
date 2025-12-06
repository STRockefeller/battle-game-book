extends Control

@onready var battle_manager: BattleManager = $BattleManager
@onready var p1_name = $HBoxContainer/Player1Panel/NameLabel
@onready var p1_hp = $HBoxContainer/Player1Panel/HpLabel
@onready var p1_mp = $HBoxContainer/Player1Panel/MpLabel
@onready var p2_name = $HBoxContainer/Player2Panel/NameLabel
@onready var p2_hp = $HBoxContainer/Player2Panel/HpLabel
@onready var p2_mp = $HBoxContainer/Player2Panel/MpLabel

@onready var instruction = $ActionPanel/InstructionLabel
@onready var moves_container = $ActionPanel/MovesContainer
@onready var log_box = $LogBox

func _ready():
	# 初始化 UI
	battle_manager.connect("turn_started", Callable(self, "_on_turn_started"))
	battle_manager.connect("action_resolved", Callable(self, "_on_action_resolved"))
	battle_manager.connect("battle_ended", Callable(self, "_on_battle_ended"))
	update_status()

func update_status():
	var p1 = battle_manager.player1
	var p2 = battle_manager.player2
	p1_name.text = p1.name
	p1_hp.text = "HP: %d / %d" % [p1.hp, p1.max_hp]
	p1_mp.text = "MP: %d / %d" % [p1.mp, p1.max_mp]
	p2_name.text = p2.name
	p2_hp.text = "HP: %d / %d" % [p2.hp, p2.max_hp]
	p2_mp.text = "MP: %d / %d" % [p2.mp, p2.max_mp]

func _on_turn_started(active_character: Character):
	update_status()
	moves_container.queue_free_children()
	instruction.text = "%s 的回合，請選擇動作：" % active_character.name

	# 如果是玩家 1，顯示選單
	if active_character == battle_manager.player1:
		for move in active_character.moves:
			var btn = Button.new()
			btn.text = move.name
			btn.disabled = not move.can_use(active_character)
			btn.connect("pressed", Callable(self, "_on_move_selected").bind(move))
			moves_container.add_child(btn)
	else:
		# AI 控制玩家 2
		var move = active_character.moves[0]
		battle_manager.perform_action(move, battle_manager.player1)

func _on_move_selected(move: Move):
	battle_manager.perform_action(move, battle_manager.player2)
	moves_container.queue_free_children()

func _on_action_resolved(user: Character, target: Character, move: Move, log: String):
	log_box.append_text(log + "\n")
	update_status()

func _on_battle_ended(winner: Character):
	instruction.text = "戰鬥結束！勝利者是 %s" % winner.name
	moves_container.queue_free_children()
