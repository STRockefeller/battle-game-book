# ClientBattleManager.gd
# 客戶端對戰管理器 - 處理玩家輸入和結果顯示
# 負責向伺服器提交動作並接收結果更新
extends BattleManager
class_name ClientBattleManager

# ==================== 網路配置 ====================

## 此客戶端對應的玩家 ID（1 或 2）
var local_player_id: int = 1

## 伺服器的 peer ID
var server_peer_id: int = 1

## 待審批的樂觀動作（已發送但未確認）
var pending_optimistic_action: Action = null

# ==================== 初始化 ====================

func _ready():
	battle_mode = MODE_CLIENT
	super._ready()

## 設置客戶端連線
func setup_client_connection(player_id: int, srv_peer_id: int) -> void:
	local_player_id = player_id
	server_peer_id = srv_peer_id
	print("[ClientBattleManager] 客戶端已設置 - 玩家:%d, 伺服器:%d" % [player_id, srv_peer_id])

# ==================== 玩家動作提交 ====================

## 提交動作到伺服器（樂觀更新）
func submit_action_to_server(action: Action) -> void:
	var local_player = get_character_by_id(local_player_id)
	
	# 驗證本地動作合法性（快速檢查）
	var available = _get_available_actions(local_player)
	if action not in available:
		print("[ClientBattleManager] 無效的動作選擇")
		return
	
	# 樂觀更新：立即在客戶端應用
	pending_optimistic_action = action
	pending_selections[local_player] = action
	selections_completed += 1
	
	print("[ClientBattleManager] 已提交動作: %s (樂觀更新)" % action.name)
	
	# 發送到伺服器（非阻塞）
	_send_action_to_server(action)
	
	# 如果是單機模式，等待 AI 做決策
	if battle_mode == MODE_SINGLEPLAYER:
		_ai_select_action()
	# 多人模式：等待伺服器確認和對方玩家的動作

## 發送動作到伺服器
func _send_action_to_server(action: Action) -> void:
	print("[ClientBattleManager] 發送動作到伺服器: %s" % action.name)
	# TODO: 使用 RPC 發送
	# rpc_id(server_peer_id, "server_player_submit_action", get_tree().get_unique_id(), action.id)

# ==================== 伺服器結果處理 ====================

## 接收伺服器的回合執行結果（來自伺服器的 RPC）
func receive_turn_execution(broadcast_data: Dictionary) -> void:
	print("[ClientBattleManager] 接收伺服器回合執行結果 - 回合:%d" % broadcast_data["turn"])
	
	# 更新本地狀態
	state.from_dict(broadcast_data["state"])
	
	# 驗證狀態一致性
	var server_hash = broadcast_data.get("state_hash", "")
	var local_hash = state.calculate_hash()
	
	if server_hash and server_hash != local_hash:
		print("[WARNING] 狀態不一致! 伺服器:%s 客戶端:%s" % [server_hash, local_hash])
		# 強制覆蓋為伺服器狀態（伺服器總是對的）
	
	# 清空待審批的樂觀更新
	pending_optimistic_action = null
	
	# 應用視覺效果和 UI 更新
	_apply_visual_effects(broadcast_data["results"])
	
	# 發送信號通知 UI
	turn_ended.emit()

## 接收狀態同步（定期心跳）
func receive_state_sync(state_data: Dictionary) -> void:
	print("[ClientBattleManager] 接收狀態同步")
	state.from_dict(state_data)
	
	# 驗證狀態
	var expected_hash = state_data.get("state_hash", "")
	if expected_hash and not state.verify_hash(expected_hash):
		print("[ERROR] 狀態驗證失敗！狀態可能被篡改")

# ==================== 視覺效果應用 ====================

## 應用動作結果的視覺效果
func _apply_visual_effects(results: Array) -> void:
	for result in results:
		print("[ClientBattleManager] 應用視覺效果: %s" % result)
		# TODO: 播放動畫、音效等

# ==================== 樂觀更新處理 ====================

## 回滾樂觀更新（如果伺服器拒絕）
func rollback_optimistic_update() -> void:
	if pending_optimistic_action:
		print("[ClientBattleManager] 回滾樂觀更新: %s" % pending_optimistic_action.name)
		pending_optimistic_action = null
		pending_selections.clear()
		selections_completed = 0

## 確認樂觀更新（伺服器接受）
func confirm_optimistic_update() -> void:
	if pending_optimistic_action:
		print("[ClientBattleManager] 確認樂觀更新: %s" % pending_optimistic_action.name)
		pending_optimistic_action = null

# ==================== 輔助方法 ====================

## 獲取本地玩家
func get_local_player() -> Character:
	return get_character_by_id(local_player_id)

## 獲取遠端玩家
func get_remote_player() -> Character:
	var remote_id = 3 - local_player_id  # 1->2 或 2->1
	return get_character_by_id(remote_id)

## 檢查是否是本地玩家的輪到
func is_local_player_turn() -> bool:
	return not pending_selections.has(get_local_player())
