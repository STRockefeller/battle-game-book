# RandomAIBehavior.gd
# 簡單 AI 實現 - 每回合從可用動作中隨機選擇一個
extends AIBehavior
class_name RandomAIBehavior

func choose_action(character: Character, available_actions: Array, opponent: Character, battle_manager: BattleManager) -> Action:
	if available_actions.size() == 0:
		return null
	
	# 隨機選擇一個可用的動作
	var random_index = randi() % available_actions.size()
	return available_actions[random_index]
