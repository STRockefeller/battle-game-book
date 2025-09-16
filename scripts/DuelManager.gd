extends Node

@onready var battle_log = $CanvasLayer/VBoxContainer/BattleLog
@onready var status_label = $CanvasLayer/VBoxContainer/StatusLabel
@onready var player1_ui = $CanvasLayer/VBoxContainer/HBoxContainer/Player1UI
@onready var player2_ui = $CanvasLayer/VBoxContainer/HBoxContainer/Player2UI

var player1: Character
var player2: Character
var move_choice_p1: Move = null
var move_choice_p2: Move = null

func _ready():
	randomize()
	# 初始化角色
	player1 = make_sample_character("勇者")
	player2 = make_sample_character("黑騎士")
	start_duel(player1, player2)

func make_sample_character(char_name: String) -> Character:
	var character = Character.new()
	character.name = char_name
	character.max_hp = 20
	character.reset()

	var attack = Move.new()
	attack.id = "attack"
	attack.name = "攻擊"
	attack.damage = 5
	attack.defense = 0

	var defend = Move.new()
	defend.id = "defend"
	defend.name = "防禦"
	defend.damage = 0
	defend.defense = 3

	character.moves = {
		"attack": attack,
		"defend": defend
	}
	return character

func start_duel(c1: Character, c2: Character):
	player1 = c1
	player2 = c2
	update_status()
	setup_ui()

func setup_ui():
	# 清掉舊按鈕
	for child in player1_ui.get_children():
		child.queue_free()
	for child in player2_ui.get_children():
		child.queue_free()

	# 建立玩家1按鈕
	for move_id in player1.moves.keys():
		var btn = Button.new()
		btn.text = player1.moves[move_id].name
		btn.connect("pressed", Callable(self, "_on_player1_move").bind(move_id))
		player1_ui.add_child(btn)

	# 建立玩家2按鈕
	for move_id in player2.moves.keys():
		var btn = Button.new()
		btn.text = player2.moves[move_id].name
		btn.connect("pressed", Callable(self, "_on_player2_move").bind(move_id))
		player2_ui.add_child(btn)

func _on_player1_move(move_id: String):
	move_choice_p1 = player1.moves[move_id]
	check_both_selected()

func _on_player2_move(move_id: String):
	move_choice_p2 = player2.moves[move_id]
	check_both_selected()

func check_both_selected():
	if move_choice_p1 != null and move_choice_p2 != null:
		resolve_turn()

func resolve_turn():
	var dmg_to_p1 = max(0, move_choice_p2.damage - move_choice_p1.defense)
	var dmg_to_p2 = max(0, move_choice_p1.damage - move_choice_p2.defense)

	player1.hp -= dmg_to_p1
	player2.hp -= dmg_to_p2

	battle_log.text += "\n" + player1.name + " 用 " + move_choice_p1.name + " ，受到 " + str(dmg_to_p1) + " 傷害"
	battle_log.text += "\n" + player2.name + " 用 " + move_choice_p2.name + " ，受到 " + str(dmg_to_p2) + " 傷害"

	update_status()

	if player1.hp <= 0 or player2.hp <= 0:
		end_duel()
	else:
		move_choice_p1 = null
		move_choice_p2 = null

func update_status():
	status_label.text = player1.name + " HP: " + str(player1.hp) + " | " + player2.name + " HP: " + str(player2.hp)

func end_duel():
	var winner = ""
	if player1.hp > 0 and player2.hp <= 0:
		winner = player1.name + " 勝利！"
	elif player2.hp > 0 and player1.hp <= 0:
		winner = player2.name + " 勝利！"
	else:
		winner = "平手！"
	battle_log.text += "\n戰鬥結束: " + winner

	# 關閉按鈕
	for child in player1_ui.get_children():
		child.disabled = true
	for child in player2_ui.get_children():
		child.disabled = true
