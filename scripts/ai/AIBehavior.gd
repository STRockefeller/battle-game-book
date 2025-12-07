# AIBehavior.gd
# AI 行為接口 - 定義 AI 做決策的方式
extends Node
class_name AIBehavior

## AI 選擇動作的方法
## 返回值：選定的 Action，或 null 如果無法選擇
func choose_action(character: Character, available_actions: Array, opponent: Character, battle_manager: BattleManager) -> Action:
	push_error("choose_action() 未實現")
	return null
