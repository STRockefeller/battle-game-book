extends Node
class_name BattleVisualPlayer

## BattleVisualPlayer 負責播放戰鬥中的視覺和音效序列
## 支援動畫、音效、特效的協調播放

signal animation_started()
signal animation_finished()
signal sequence_completed()

# 播放狀態
enum PlaybackState {
	IDLE,
	PLAYING,
	PAUSED
}

var current_state: PlaybackState = PlaybackState.IDLE
var asset_manager: AssetManager = null

# 當前播放的節點引用
var _audio_player: AudioStreamPlayer = null
var _vfx_instances: Array[Node] = []
var _animation_timer: Timer = null

func _ready() -> void:
	# 取得或建立AssetManager實例
	asset_manager = AssetManager.get_instance()
	if not asset_manager.is_inside_tree():
		get_tree().root.add_child(asset_manager)
	
	# 建立音效播放器
	_audio_player = AudioStreamPlayer.new()
	_audio_player.name = "BattleAudioPlayer"
	add_child(_audio_player)
	
	# 建立動畫計時器
	_animation_timer = Timer.new()
	_animation_timer.name = "AnimationTimer"
	_animation_timer.one_shot = true
	add_child(_animation_timer)
	_animation_timer.timeout.connect(_on_animation_timer_timeout)

## 播放完整的動作序列
## @param character_sprite: 角色精靈節點
## @param visual_state: 角色視覺狀態
## @param action_assets: 動作資源定義
## @param character_assets: 角色資源定義（用於loading)
func play_action_sequence(
	character_sprite: Sprite2D,
	visual_state: CharacterVisualState,
	action_assets,
	character_assets
) -> void:
	if current_state == PlaybackState.PLAYING:
		push_warning("BattleVisualPlayer: 已有動畫正在播放")
		return
	
	current_state = PlaybackState.PLAYING
	animation_started.emit()
	
	# 1. 更新角色精靈圖
	_update_character_sprite(character_sprite, visual_state, character_assets)
	
	# 2. 播放音效
	if action_assets and not action_assets.audio_cast.is_empty():
		_play_audio(action_assets.audio_cast)
	
	# 3. 播放特效
	if action_assets and not action_assets.vfx_cast.is_empty():
		_play_vfx(action_assets.vfx_cast, character_sprite.global_position)
	
	# 4. 設定動畫持續時間
	var duration = action_assets.animation_duration if action_assets else 0.5
	_animation_timer.start(duration)

## 播放角色受擊序列
## @param character_sprite: 角色精靈節點
## @param visual_state: 角色視覺狀態
## @param character_assets: 角色資源定義
## @param hit_vfx_path: 受擊特效路徑（可選，會覆蓋預設）
## @param duration: 動畫持續時間
func play_hit_sequence(
	character_sprite: Sprite2D,
	visual_state: CharacterVisualState,
	character_assets,
	hit_vfx_path: String = "",
	duration: float = 0.3
) -> void:
	# 設定受擊姿勢
	visual_state.set_pose(CharacterVisualState.Pose.HIT)
	
	current_state = PlaybackState.PLAYING
	animation_started.emit()
	
	# 更新精靈圖
	_update_character_sprite(character_sprite, visual_state, character_assets)
	
	# 播放音效
	if character_assets and not character_assets.audio_hit.is_empty():
		_play_audio(character_assets.audio_hit)
	
	# 播放特效
	var vfx_path = hit_vfx_path if not hit_vfx_path.is_empty() else "res://assets/vfx/default_effect.tscn"
	if not vfx_path.is_empty():
		_play_vfx(vfx_path, character_sprite.global_position)
	
	# 設定動畫時長
	_animation_timer.start(duration)

## 播放角色待機動畫
## @param character_sprite: 角色精靈節點
## @param visual_state: 角色視覺狀態
## @param character_assets: 角色資源定義
func play_idle(character_sprite: Sprite2D, visual_state: CharacterVisualState, character_assets) -> void:
	visual_state.set_pose(CharacterVisualState.Pose.IDLE)
	_update_character_sprite(character_sprite, visual_state, character_assets)

## 播放勝利動畫
## @param character_sprite: 角色精靈節點
## @param visual_state: 角色視覺狀態
## @param character_assets: 角色資源定義
func play_victory(character_sprite: Sprite2D, visual_state: CharacterVisualState, character_assets) -> void:
	visual_state.set_pose(CharacterVisualState.Pose.VICTORY)
	
	current_state = PlaybackState.PLAYING
	animation_started.emit()
	
	_update_character_sprite(character_sprite, visual_state, character_assets)
	
	# 播放音效
	if character_assets and not character_assets.audio_victory.is_empty():
		_play_audio(character_assets.audio_victory)
	
	_animation_timer.start(1.0)

## 播放失敗動畫
## @param character_sprite: 角色精靈節點
## @param visual_state: 角色視覺狀態
## @param character_assets: 角色資源定義
func play_defeat(character_sprite: Sprite2D, visual_state: CharacterVisualState, character_assets) -> void:
	visual_state.set_pose(CharacterVisualState.Pose.DEFEAT)
	_update_character_sprite(character_sprite, visual_state, character_assets)

## 更新角色精靈圖
func _update_character_sprite(sprite: Sprite2D, visual_state: CharacterVisualState, character_assets) -> void:
	if sprite == null or character_assets == null:
		return
	
	# 取得精靈圖路徑（帶fallback）
	var sprite_paths = visual_state.get_sprite_paths(character_assets)
	
	# 嘗試載入精靈圖
	for path in sprite_paths:
		var texture = asset_manager.load_asset(path, AssetManager.AssetType.SPRITE)
		if texture != null and texture is Texture2D:
			sprite.texture = texture
			return
	
	# 如果所有路徑都失敗，使用預設精靈圖
	var default_texture = asset_manager.load_asset("", AssetManager.AssetType.SPRITE)
	if default_texture != null:
		sprite.texture = default_texture

## 播放音效
func _play_audio(audio_path: String) -> void:
	var audio_stream = asset_manager.load_asset(audio_path, AssetManager.AssetType.AUDIO)
	if audio_stream != null and audio_stream is AudioStream:
		_audio_player.stream = audio_stream
		_audio_player.play()

## 播放特效
func _play_vfx(vfx_path: String, position: Vector2) -> void:
	var vfx_scene = asset_manager.load_asset(vfx_path, AssetManager.AssetType.VFX)
	if vfx_scene == null or not vfx_scene is PackedScene:
		return
	
	var vfx_instance = vfx_scene.instantiate()
	if vfx_instance == null:
		return
	
	# 添加到場景樹
	get_tree().root.add_child(vfx_instance)
	_vfx_instances.append(vfx_instance)
	
	# 設定位置
	if vfx_instance is Node2D:
		vfx_instance.global_position = position
	
	# 自動清理：如果特效有動畫播放器，監聽完成信號
	if vfx_instance.has_signal("animation_finished"):
		vfx_instance.animation_finished.connect(_on_vfx_finished.bind(vfx_instance))
	else:
		# 否則在3秒後自動清理
		get_tree().create_timer(3.0).timeout.connect(_cleanup_vfx.bind(vfx_instance))

## 動畫計時器超時
func _on_animation_timer_timeout() -> void:
	current_state = PlaybackState.IDLE
	animation_finished.emit()
	sequence_completed.emit()

## 特效播放完成
func _on_vfx_finished(_anim_name: String, vfx_instance: Node) -> void:
	_cleanup_vfx(vfx_instance)

## 清理特效實例
func _cleanup_vfx(vfx_instance: Node) -> void:
	if vfx_instance == null or not is_instance_valid(vfx_instance):
		return
	
	var index = _vfx_instances.find(vfx_instance)
	if index >= 0:
		_vfx_instances.remove_at(index)
	
	if vfx_instance.is_inside_tree():
		vfx_instance.queue_free()

## 停止當前播放
func stop() -> void:
	current_state = PlaybackState.IDLE
	
	if _audio_player.playing:
		_audio_player.stop()
	
	if _animation_timer.time_left > 0:
		_animation_timer.stop()
	
	# 清理所有特效
	for vfx in _vfx_instances:
		if is_instance_valid(vfx) and vfx.is_inside_tree():
			vfx.queue_free()
	_vfx_instances.clear()

## 暫停播放
func pause() -> void:
	if current_state == PlaybackState.PLAYING:
		current_state = PlaybackState.PAUSED
		_audio_player.stream_paused = true
		_animation_timer.paused = true

## 恢復播放
func resume() -> void:
	if current_state == PlaybackState.PAUSED:
		current_state = PlaybackState.PLAYING
		_audio_player.stream_paused = false
		_animation_timer.paused = false

## 檢查是否正在播放
func is_playing() -> bool:
	return current_state == PlaybackState.PLAYING
