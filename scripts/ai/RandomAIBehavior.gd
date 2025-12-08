# RandomAI.gd
# 隨機 AI - 從可用動作中隨機選擇
extends AIBehavior
class_name RandomAI

func choose_action(character: Character, available_actions: Array, _opponent: Character, battle_manager: BattleManager) -> Action:
	if available_actions.size() == 0:
		return null
	
	# 過濾出實際可以使用的動作
	var affordable_actions = get_affordable_actions(available_actions, character, battle_manager)
	
	if affordable_actions.size() == 0:
		# 如果所有動作都用不了，嘗試找最低消耗的
		return _find_cheapest_action(available_actions)
	
	# 隨機選擇一個可用的動作
	var random_index = randi() % affordable_actions.size()
	return affordable_actions[random_index]

## 找到消耗最低的動作（備用方案）
func _find_cheapest_action(actions: Array) -> Action:
	if actions.size() == 0:
		return null
	
	var cheapest: Action = actions[0]
	var min_cost = cheapest.cost_stamina + cheapest.cost_mp
	
	for action in actions:
		var cost = action.cost_stamina + action.cost_mp
		if cost < min_cost:
			min_cost = cost
			cheapest = action
	
	return cheapest
