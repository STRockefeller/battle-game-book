# StoryModeTest.gd
# 故事模式測試場景

extends Control

@onready var energy_label: Label = $InfoPanel/VBoxContainer/EnergyLabel
@onready var stage_label: Label = $InfoPanel/VBoxContainer/StageLabel
@onready var battles_label: Label = $InfoPanel/VBoxContainer/BattlesLabel
@onready var events_label: Label = $InfoPanel/VBoxContainer/EventsLabel

@onready var start_button: Button = $TestPanel/VBoxContainer/StartButton
@onready var add_energy_button: Button = $TestPanel/VBoxContainer/AddEnergyButton
@onready var remove_energy_button: Button = $TestPanel/VBoxContainer/RemoveEnergyButton
@onready var trigger_event_button: Button = $TestPanel/VBoxContainer/TriggerEventButton
@onready var back_button: Button = $TestPanel/VBoxContainer/BackButton

@onready var log_text: RichTextLabel = $LogPanel/VBoxContainer/ScrollContainer/LogText

var test_story: StoryData = null

func _ready():
	_connect_signals()
	_create_test_story()
	_update_ui()
	_log("Story Mode Test Scene Loaded")

func _connect_signals():
	start_button.pressed.connect(_on_start_pressed)
	add_energy_button.pressed.connect(_on_add_energy_pressed)
	remove_energy_button.pressed.connect(_on_remove_energy_pressed)
	trigger_event_button.pressed.connect(_on_trigger_event_pressed)
	back_button.pressed.connect(_on_back_pressed)
	
	# Connect StoryManager signals
	StoryManager.story_started.connect(_on_story_started)
	StoryManager.world_energy_changed.connect(_on_energy_changed)
	StoryManager.calamity_stage_changed.connect(_on_stage_changed)
	StoryManager.story_event_triggered.connect(_on_event_triggered)

func _create_test_story():
	# Create a minimal test story
	test_story = StoryData.new()
	test_story.story_id = "test_story"
	test_story.character_id = "elise"
	test_story.story_title = "測試故事"
	test_story.homeland_name = "測試之森"
	test_story.energy_type = "life"
	test_story.initial_world_energy = 50.0
	test_story.opening_narrative = "這是一個測試故事，用來驗證故事系統是否正常運作。"
	
	# Create test stages
	var stage_stable = CalamityStage.new()
	stage_stable.stage_id = "stable"
	stage_stable.stage_name = "穩定期"
	stage_stable.min_energy = 80.0
	stage_stable.max_energy = 100.0
	stage_stable.stage_narrative = "一切正常"
	
	var stage_initial = CalamityStage.new()
	stage_initial.stage_id = "initial"
	stage_initial.stage_name = "初期災變"
	stage_initial.min_energy = 60.0
	stage_initial.max_energy = 79.9
	stage_initial.stage_narrative = "開始出現問題"
	
	var stage_crisis = CalamityStage.new()
	stage_crisis.stage_id = "crisis"
	stage_crisis.stage_name = "危機期"
	stage_crisis.min_energy = 40.0
	stage_crisis.max_energy = 59.9
	stage_crisis.stage_narrative = "情況變得嚴重"
	
	var stage_collapse = CalamityStage.new()
	stage_collapse.stage_id = "collapse"
	stage_collapse.stage_name = "崩壞期"
	stage_collapse.min_energy = 0.0
	stage_collapse.max_energy = 39.9
	stage_collapse.stage_narrative = "瀕臨毀滅"
	
	test_story.calamity_stages = [stage_stable, stage_initial, stage_crisis, stage_collapse]
	
	# Create test event
	var test_event = StoryEvent.new()
	test_event.event_id = "test_event_1"
	test_event.event_title = "測試事件"
	test_event.event_description = "這是一個測試事件，當能量降到50%以下時觸發"
	test_event.trigger_type = "energy"
	test_event.trigger_value = 50.0
	test_event.event_type = "narrative"
	test_event.energy_change = 10.0
	
	test_story.story_events = [test_event]
	
	# Add to cache
	StoryManager.story_data_cache["test"] = test_story
	
	_log("Test story created successfully")

func _on_start_pressed():
	if StoryManager.current_story != null:
		_log("Story already started. Restarting...")
		StoryManager.end_story()
	
	var success = StoryManager.start_story("test")
	if success:
		_log("Story started successfully!")
		_update_ui()
	else:
		_log("Failed to start story")

func _on_add_energy_pressed():
	if StoryManager.current_progress == null:
		_log("Please start story first")
		return
	
	StoryManager.add_world_energy(10.0)
	_log("Added 10 energy")
	_update_ui()

func _on_remove_energy_pressed():
	if StoryManager.current_progress == null:
		_log("Please start story first")
		return
	
	StoryManager.remove_world_energy(10.0)
	_log("Removed 10 energy")
	_update_ui()

func _on_trigger_event_pressed():
	if StoryManager.current_progress == null:
		_log("Please start story first")
		return
	
	StoryManager.check_event_triggers()
	_log("Checked for event triggers")

func _on_back_pressed():
	get_tree().change_scene_to_file("res://scenes/main_menu/MainMenu.tscn")

func _on_story_started(story: StoryData):
	_log("=== STORY STARTED ===")
	_log("Story: " + story.story_title)
	_log("Initial Energy: " + str(story.initial_world_energy))

func _on_energy_changed(new_energy: float, change: float):
	var sign = "+" if change > 0 else ""
	_log("Energy Changed: " + sign + str(change) + " → " + str(new_energy))

func _on_stage_changed(stage: CalamityStage):
	_log("=== STAGE CHANGED ===")
	_log("New Stage: " + stage.stage_name)
	_log("Narrative: " + stage.stage_narrative)

func _on_event_triggered(event: StoryEvent):
	_log("=== EVENT TRIGGERED ===")
	_log("Event: " + event.event_title)
	_log("Description: " + event.event_description)
	
	# Auto-complete the event for testing
	StoryManager.complete_event(event.event_id)
	_log("Event auto-completed")

func _update_ui():
	if StoryManager.current_progress == null:
		energy_label.text = "Energy: N/A (Story not started)"
		stage_label.text = "Stage: N/A"
		battles_label.text = "Battles: 0"
		events_label.text = "Events: 0"
		
		add_energy_button.disabled = true
		remove_energy_button.disabled = true
		trigger_event_button.disabled = true
	else:
		var energy = StoryManager.current_progress.world_energy
		energy_label.text = "Energy: %.1f%%" % energy
		
		var stage = StoryManager.current_story.get_current_calamity_stage(energy)
		if stage:
			stage_label.text = "Stage: " + stage.stage_name
		else:
			stage_label.text = "Stage: Unknown"
		
		battles_label.text = "Battles: " + str(StoryManager.current_progress.battles_completed)
		events_label.text = "Events: " + str(StoryManager.current_progress.completed_events.size())
		
		add_energy_button.disabled = false
		remove_energy_button.disabled = false
		trigger_event_button.disabled = false

func _log(message: String):
	var timestamp = Time.get_time_string_from_system()
	log_text.append_text("[" + timestamp + "] " + message + "\n")
	print(message)
