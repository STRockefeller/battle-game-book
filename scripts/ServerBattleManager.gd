# ServerBattleManager.gd
# 伺服器端對戰管理器 - 處理多人遊戲中的所有計算和驗證
# 負責驗證玩家動作、執行計算並廣播結果給雙方客戶端
extends BattleManager
class_name ServerBattleManager

# ==================== RNG 管理 ====================

## 確定性隨機數生成器種子計數器
var rng_seed_counter: int = 0

## 用於驗證客戶端計算結果的種子列表
var rng_seeds: Array[int] = []

# ==================== 多人模式配置 ====================

## 玩家 1 的網路節點 ID
var player1_peer_id: int = 0

## 玩家 2 的網路節點 ID
var player2_peer_id: int = 0

# ==================== 初始化 ====================

func _ready():
	battle_mode = MODE_SERVER
	super._ready()

## 設置伺服器對戰（指定雙方的 peer ID）
func setup_multiplayer(p1_peer: int, p2_peer: int) -> void:
	player1_peer_id = p1_peer
	player2_peer_id = p2_peer
	print("[ServerBattleManager] 多人對戰設置 - P1:%d, P2:%d" % [p1_peer, p2_peer])

# ==================== 動作驗證 ====================

## 驗證客戶端提交的動作（主要驗證點）
func validate_player_action(peer_id: int, action: Action) -> Dictionary:
	# 確定玩家
	var player = player1 if peer_id == player1_peer_id else player2
	var player_id = get_player_id(player)
	
	print("[ServerBattleManager] 驗證玩家 %d 的動作: %s" % [player_id, action.name])
	
	# 檢查是否輪到此玩家
	if pending_selections.has(player):
		return {
			"valid": false,
			"error": "Player already submitted action for this turn"
		}
	
	# 取得當前冷卻和資源
	var cooldowns = _get_player_cooldowns(player)
	var current_stamina = get_current_stamina(player)
	var current_mp = get_current_mp(player)
	
	# 使用 BattleLogic 驗證動作（直接調用靜態方法）
	var validation_result = {
		"valid": true,
		"errors": []
	}
	
	# 檢查冷卻
	if cooldowns.has(action.id) and cooldowns[action.id] > 0:
		validation_result["valid"] = false
		validation_result["errors"].append("Action is on cooldown")
	
	# 檢查資源
	if current_stamina < action.cost_stamina or current_mp < action.cost_mp:
		validation_result["valid"] = false
		validation_result["errors"].append("Insufficient resources")
	
	# 檢查 HP（健全性檢查）
	if current_stamina < 0 or current_stamina > player.max_stamina:
		validation_result["valid"] = false
		validation_result["errors"].append("Invalid stamina state")
	if current_mp < 0 or current_mp > player.max_mp:
		validation_result["valid"] = false
		validation_result["errors"].append("Invalid MP state")
	
	if not validation_result["valid"]:
		print("  [驗證失敗] %s" % ", ".join(validation_result["errors"]))
		return {
			"valid": false,
			"error": "Action validation failed: " + ", ".join(validation_result["errors"])
		}
	
	# 檢查動作是否在角色的可用動作中
	var available = _get_available_actions(player)
	if action not in available:
		print("  [驗證失敗] 動作不在可用列表中")
		return {
			"valid": false,
			"error": "Action not in available actions"
		}
	
	print("  [驗證成功]")
	return { "valid": true }

## 伺服器端玩家提交動作（來自客戶端的 RPC）
func server_player_submit_action(peer_id: int, action_id: String) -> void:
	# 根據 peer_id 找到對應的角色
	var player = player1 if peer_id == player1_peer_id else player2
	
	# 根據 action_id 找到 Action 物件
	var action = _find_action_by_id(player, action_id)
	if not action:
		print("[ERROR] 無法找到動作: %s" % action_id)
		return
	
	# 驗證動作
	var validation = validate_player_action(peer_id, action)
	if not validation["valid"]:
		print("[ERROR] 動作驗證失敗: %s" % validation["error"])
		# 可選：發送錯誤訊息回客戶端
		return
	
	# 記錄選擇
	pending_selections[player] = action
	selections_completed += 1
	
	print("[ServerBattleManager] 玩家 %d 已提交動作: %s (%d/2)" % [get_player_id(player), action.name, selections_completed])
	
	# 檢查是否所有玩家都提交了
	if selections_completed >= 2:
		_all_selections_complete()

## 伺服器廣播回合執行結果到雙方客戶端
func broadcast_turn_execution(execution_order: Array, results: Array) -> void:
	var broadcast_data = {
		"turn": state.turn,
		"state": state.to_dict(),
		"execution_order": [],
		"results": results,
		"rng_seeds": rng_seeds.duplicate()
	}
	
	# 為執行順序的每個動作記錄 RNG 種子（用於客戶端驗證）
	for i in range(execution_order.size()):
		var action_data = execution_order[i]
		broadcast_data["execution_order"].append({
			"user_id": get_player_id(action_data["user"]),
			"action_id": action_data["action"].id,
			"rng_seed": rng_seeds[i] if i < rng_seeds.size() else 0
		})
	
	# 廣播到雙方
	print("[ServerBattleManager] 廣播回合 %d 結果到客戶端" % state.turn)
	# TODO: 使用 RPC 廣播
	# rpc("receive_turn_execution", broadcast_data)

# ==================== 覆寫執行邏輯以支援確定性計算 ====================

## 覆寫命中判定以使用確定性 RNG
func _roll_hit(action_accuracy: float, accuracy_bonus: int) -> bool:
	# 使用確定性種子執行計算
	var result = BattleLogic.calculate_hit_static(action_accuracy, accuracy_bonus, rng_seed_counter)
	
	rng_seeds.append(rng_seed_counter)
	rng_seed_counter += 1
	
	return result

# ==================== 輔助方法 ====================

## 根據 action_id 在角色的可用動作中查找
func _find_action_by_id(character: Character, action_id: String) -> Action:
	for action in character.available_actions:
		if action.id == action_id:
			return action
	return null

## 廣播狀態給特定客戶端（用於同步）
func broadcast_state_to_peer(peer_id: int) -> void:
	var state_data = state.to_dict()
	state_data["state_hash"] = state.calculate_hash()
	print("[ServerBattleManager] 廣播狀態給客戶端 %d: hash=%s" % [peer_id, state_data["state_hash"]])
	# TODO: 使用 RPC 廣播
	# rpc_id(peer_id, "receive_state_sync", state_data)

## 驗證客戶端的狀態是否與伺服器一致
func verify_client_state(peer_id: int, client_state_hash: String) -> bool:
	var server_hash = state.calculate_hash()
	var match = client_state_hash == server_hash
	
	if not match:
		print("[WARNING] 客戶端 %d 狀態不匹配! 伺服器:%s 客戶端:%s" % [peer_id, server_hash, client_state_hash])
	
	return match
