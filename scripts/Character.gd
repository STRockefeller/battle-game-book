extends Resource
class_name Character

var name: String
var max_hp: int = 20
var hp: int = 20
var moves: Dictionary = {}   # "attack" -> Move, "defend" -> Move
var status_effects: Array = []

func reset():
    hp = max_hp
    status_effects.clear()
