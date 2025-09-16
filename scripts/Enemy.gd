# Enemy.gd
extends Resource
class_name Enemy

var name: String
var hp: int
var attack: int
var defense: int

func _init(enemy_name: String):
    name = enemy_name
    match name:
        "wolf":
            hp = 10
            attack = 3
            defense = 1
        _:
            hp = 5
            attack = 2
            defense = 1
