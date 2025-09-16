# BattleSystem.gd
extends Node
class_name BattleSystem

func fight(player, enemy):
    print("與 " + enemy.name + " 戰鬥！")
    
    while player.hp > 0 and enemy.hp > 0:
        var player_roll = randi_range(1, 6)
        var enemy_roll = randi_range(1, 6)

        var player_damage = max(0, player.attack + player_roll - enemy.defense)
        var enemy_damage = max(0, enemy.attack + enemy_roll - player.defense)

        enemy.hp -= player_damage
        player.hp -= enemy_damage

        print("你造成 " + str(player_damage) + " 傷害，" + enemy.name + " 剩下 " + str(enemy.hp))
        print(enemy.name + " 造成 " + str(enemy_damage) + " 傷害，你剩下 " + str(player.hp))

    if player.hp > 0:
        print("你勝利了！")
        return "win"
    else:
        print("你被打敗了...")
        return "lose"
