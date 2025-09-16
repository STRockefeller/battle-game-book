extends Node

@onready var story_label = $CanvasLayer/VBoxContainer/StoryLabel
@onready var options_container = $CanvasLayer/VBoxContainer/Options

var current_chapter = "intro"
var player
var chapters = {}

func _ready():
	randomize()
	load_chapters()
	player = Player.new()
	show_chapter(current_chapter)

func load_chapters():
	chapters = {
		"intro": {
			"text": "你站在黑暗森林的入口，要往哪裡走？",
			"options": [
				{"text": "往左走", "next": "left_path"},
				{"text": "往右走", "next": "right_path"}
			]
		},
		"left_path": {
			"text": "一隻野狼出現！準備戰鬥！",
			"battle": {"enemy": "wolf", "next": "after_wolf"}
		},
		"after_wolf": {
			"text": "你打敗了野狼，繼續前進。",
			"options": [
				{"text": "繼續前進", "next": "deep_forest"}
			]
		},
		"right_path": {
			"text": "你來到一片平靜的湖邊。",
			"options": [
				{"text": "休息一下", "next": "rest"}
			]
		}
	}

func show_chapter(chapter_name: String):
	current_chapter = chapter_name
	var data = chapters[chapter_name]

	# 顯示章節文字
	story_label.text = data["text"]

	# 清空舊選項
	for child in options_container.get_children():
		child.queue_free()

	# 如果是戰鬥章節 → 啟動戰鬥
	if "battle" in data:
		start_battle(data["battle"]["enemy"], data["battle"]["next"])
		return

	# 動態生成選項按鈕
	if "options" in data:
		for option in data["options"]:
			var btn = Button.new()
			btn.text = option["text"]
			btn.connect("pressed", Callable(self, "_on_option_selected").bind(option["next"]))
			options_container.add_child(btn)

func _on_option_selected(next_chapter: String):
	show_chapter(next_chapter)

func start_battle(enemy_name: String, next_chapter: String):
	var enemy = Enemy.new(enemy_name)
	var battle = BattleSystem.new()
	var result = battle.fight(player, enemy)

	# 戰鬥結果文字
	if result == "win":
		story_label.text = "你打敗了 " + enemy.name + "！"
		var btn = Button.new()
		btn.text = "繼續"
		btn.connect("pressed", Callable(self, "_on_option_selected").bind(next_chapter))
		options_container.add_child(btn)
	else:
		story_label.text = "你戰敗了... 遊戲結束。"
