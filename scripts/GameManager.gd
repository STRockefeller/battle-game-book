# GameManager.gd
extends Node

class_name GameManager

const Player = preload("res://scripts/Player.gd")
const Enemy = preload("res://scripts/Enemy.gd")
const BattleSystem = preload("res://scripts/BattleSystem.gd")

var current_chapter = "intro"
var player
var chapters = {} # 章節資料

func _ready():
    load_chapters()
    player = Player.new()
    show_chapter(current_chapter)

func load_chapters():
    # 每個章節包含文字、選項、可能進入戰鬥
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

func show_chapter(name: String):
    current_chapter = name
    var data = chapters[name]
    print("\n--- " + name + " ---")
    print(data["text"])
    
    if "battle" in data:
        start_battle(data["battle"]["enemy"], data["battle"]["next"])
        return

    if "options" in data:
        for i in data["options"].size():
            print(str(i+1) + ". " + data["options"][i]["text"])

func choose_option(index: int):
    var options = chapters[current_chapter]["options"]
    if index >= 0 and index < options.size():
        show_chapter(options[index]["next"])

func start_battle(enemy_name: String, next_chapter: String):
    var enemy = Enemy.new(enemy_name)
    var battle = BattleSystem.new()
    var result = battle.fight(player, enemy)
    if result == "win":
        show_chapter(next_chapter)
    else:
        print("你戰敗了... 遊戲結束。")

