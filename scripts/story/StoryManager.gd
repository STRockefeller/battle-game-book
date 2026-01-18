# StoryManager.gd
# 故事模式管理器 - 自動加載的單例，管理故事流程

extends Node

# ==================== 信號 ====================
signal story_started(story_data: StoryData)
signal story_event_triggered(event: StoryEvent)
signal world_energy_changed(new_energy: float, change_amount: float)
signal calamity_stage_changed(stage: CalamityStage)
signal story_ended(ending_type: String)
signal truth_fragment_unlocked(fragment_id: String, total_count: int)

# ==================== 當前狀態 ====================
var current_story: StoryData = null
var current_progress: StoryProgress = null
var pending_events: Array[StoryEvent] = []

# ==================== 故事資源緩存 ====================
var story_data_cache: Dictionary = {}  # {character_id: StoryData}

# ==================== 初始化 ====================
func _ready() -> void:
	load_all_stories()

## 加載所有故事數據
func load_all_stories() -> void:
	# TODO: 從資源文件夾自動加載所有故事
	pass

# ==================== 故事控制 ====================

## 開始新故事
func start_story(character_id: String) -> bool:
	if not story_data_cache.has(character_id):
		push_error("Story data not found for character: " + character_id)
		return false
	
	current_story = story_data_cache[character_id]
	current_progress = StoryProgress.new()
	current_progress.story_id = current_story.story_id
	current_progress.character_id = character_id
	current_progress.world_energy = current_story.initial_world_energy
	
	# 初始化解鎖事件
	for event in current_story.story_events:
		if event is StoryEvent and event.trigger_type == "manual":
			current_progress.unlock_event(event.event_id)
	
	story_started.emit(current_story)
	check_stage_change()
	return true

## 繼續已存在的故事
func continue_story(progress: StoryProgress) -> bool:
	if not story_data_cache.has(progress.character_id):
		push_error("Story data not found for character: " + progress.character_id)
		return false
	
	current_story = story_data_cache[progress.character_id]
	current_progress = progress
	
	story_started.emit(current_story)
	check_stage_change()
	return true

## 結束故事
func end_story() -> void:
	if current_story == null or current_progress == null:
		return
	
	var ending_type = current_story.get_ending_type(current_progress.world_energy)
	story_ended.emit(ending_type)
	
	# 保存進度到元數據
	save_meta_progression()
	
	current_story = null
	current_progress = null

# ==================== 能量系統 ====================

## 增加世界能量
func add_world_energy(amount: float) -> void:
	if current_progress == null:
		return
	
	var old_energy = current_progress.world_energy
	current_progress.add_energy(amount)
	var new_energy = current_progress.world_energy
	
	world_energy_changed.emit(new_energy, amount)
	check_stage_change()
	check_event_triggers()

## 減少世界能量
func remove_world_energy(amount: float) -> void:
	if current_progress == null:
		return
	
	var old_energy = current_progress.world_energy
	current_progress.remove_energy(amount)
	var new_energy = current_progress.world_energy
	
	world_energy_changed.emit(new_energy, -amount)
	check_stage_change()
	check_event_triggers()

## 檢查災變階段變化
func check_stage_change() -> void:
	if current_story == null or current_progress == null:
		return
	
	var new_stage = current_story.get_current_calamity_stage(current_progress.world_energy)
	if new_stage != null:
		calamity_stage_changed.emit(new_stage)
		
		# 觸發階段相關事件
		for event_id in new_stage.triggered_events:
			trigger_event_by_id(event_id)

# ==================== 事件系統 ====================

## 檢查並觸發符合條件的事件
func check_event_triggers() -> void:
	if current_story == null or current_progress == null:
		return
	
	for event in current_story.story_events:
		if event is StoryEvent:
			# 檢查是否已完成
			if current_progress.completed_events.has(event.event_id):
				continue
			
			# 檢查觸發條件
			var progress_dict = {
				"world_energy": current_progress.world_energy,
				"battles_completed": current_progress.battles_completed,
				"current_stage": current_progress.current_stage
			}
			
			if event.can_trigger(progress_dict):
				trigger_event(event)

## 根據ID觸發事件
func trigger_event_by_id(event_id: String) -> void:
	if current_story == null:
		return
	
	for event in current_story.story_events:
		if event is StoryEvent and event.event_id == event_id:
			trigger_event(event)
			return

## 觸發事件
func trigger_event(event: StoryEvent) -> void:
	if current_progress == null:
		return
	
	# 添加到待處理事件隊列
	if not pending_events.has(event):
		pending_events.append(event)
		story_event_triggered.emit(event)

## 完成事件
func complete_event(event_id: String, chosen_choice: EventChoice = null) -> void:
	if current_progress == null:
		return
	
	current_progress.complete_event(event_id)
	
	# 應用事件效果
	var event = get_event_by_id(event_id)
	if event != null:
		apply_event_effects(event, chosen_choice)
	
	# 從待處理隊列移除
	for i in range(pending_events.size() - 1, -1, -1):
		if pending_events[i].event_id == event_id:
			pending_events.remove_at(i)

## 應用事件效果
func apply_event_effects(event: StoryEvent, choice: EventChoice = null) -> void:
	var energy_change = event.energy_change
	var flags = event.story_flags.duplicate()
	var unlock_abilities = event.unlock_abilities.duplicate()
	var lock_abilities = event.lock_abilities.duplicate()
	
	# 如果有選擇，使用選擇的效果
	if choice != null:
		energy_change += choice.energy_change
		for key in choice.story_flags:
			flags[key] = choice.story_flags[key]
		unlock_abilities.append_array(choice.unlock_abilities)
		lock_abilities.append_array(choice.lock_abilities)
		
		# 記錄道德選擇
		if choice.moral_alignment != "":
			current_progress.record_moral_choice(choice.choice_id, choice.moral_alignment)
		
		# 解鎖後續事件
		for unlock_event_id in choice.unlock_events:
			current_progress.unlock_event(unlock_event_id)
	
	# 應用能量變化
	if energy_change != 0:
		if energy_change > 0:
			add_world_energy(energy_change)
		else:
			remove_world_energy(-energy_change)
	
	# 應用故事標記
	for key in flags:
		current_progress.story_flags[key] = flags[key]
	
	# 應用能力變化
	for ability in unlock_abilities:
		if not current_progress.unlocked_abilities.has(ability):
			current_progress.unlocked_abilities.append(ability)
	
	for ability in lock_abilities:
		if not current_progress.locked_abilities.has(ability):
			current_progress.locked_abilities.append(ability)

## 根據ID獲取事件
func get_event_by_id(event_id: String) -> StoryEvent:
	if current_story == null:
		return null
	
	for event in current_story.story_events:
		if event is StoryEvent and event.event_id == event_id:
			return event
	
	return null

# ==================== 戰鬥整合 ====================

## 戰鬥勝利處理
func on_battle_victory(energy_gained: float) -> void:
	if current_progress == null:
		return
	
	current_progress.battles_completed += 1
	add_world_energy(energy_gained)

## 戰鬥失敗處理
func on_battle_defeat(energy_lost: float) -> void:
	if current_progress == null:
		return
	
	current_progress.battles_completed += 1
	remove_world_energy(energy_lost)

# ==================== 真相系統 ====================

## 解鎖真相碎片
func unlock_truth_fragment(fragment_id: String) -> void:
	if current_progress == null:
		return
	
	current_progress.add_truth_fragment(fragment_id)
	truth_fragment_unlocked.emit(fragment_id, current_progress.truth_progress)
	
	# 檢查是否解鎖隱藏劇情
	if current_progress.can_access_secret_ending():
		unlock_secret_ending()

## 解鎖隱藏結局
func unlock_secret_ending() -> void:
	# 觸發特殊事件
	trigger_event_by_id("secret_ending_unlock")

# ==================== 保存/加載 ====================

## 保存當前進度
func save_progress() -> Dictionary:
	if current_progress == null:
		return {}
	
	return {
		"story_id": current_progress.story_id,
		"character_id": current_progress.character_id,
		"world_energy": current_progress.world_energy,
		"total_energy_gained": current_progress.total_energy_gained,
		"battles_completed": current_progress.battles_completed,
		"completed_events": current_progress.completed_events,
		"story_flags": current_progress.story_flags,
		"truth_fragments": current_progress.truth_fragments
	}

## 保存元進度（跨周目）
func save_meta_progression() -> void:
	# TODO: 實現元進度系統（記憶圖書館、永久解鎖等）
	pass
