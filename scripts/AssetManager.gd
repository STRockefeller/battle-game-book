extends Node
class_name AssetManager

## AssetManager 負責管理遊戲中所有視覺和音頻資源的載入
## 支援fallback機制，當指定資源不存在時，會嘗試載入預設資源

# 資源類型枚舉
enum AssetType {
	SPRITE,
	ANIMATION,
	AUDIO,
	VFX
}

# 預設資源路徑
const DEFAULT_PATHS = {
	AssetType.SPRITE: "res://assets/sprites/default_character.svg",
	AssetType.ANIMATION: "res://assets/sprites/default_animation.tres",
	AssetType.AUDIO: "res://assets/audio/default_sound.ogg",
	AssetType.VFX: "res://assets/vfx/default_effect.tscn"
}

# 資源快取
var _cache: Dictionary = {}

# 單例模式
static var _instance: AssetManager = null

static func get_instance() -> AssetManager:
	if _instance == null:
		_instance = AssetManager.new()
		_instance.name = "AssetManager"
	return _instance

## 載入資源，支援fallback機制
## @param path: 資源路徑
## @param asset_type: 資源類型
## @param use_cache: 是否使用快取，預設true
## @return 載入的資源，如果載入失敗則返回預設資源
func load_asset(path: String, asset_type: AssetType, use_cache: bool = true) -> Resource:
	# 如果路徑為空，直接返回預設資源
	if path.is_empty():
		return _load_default_asset(asset_type)
	
	# 檢查快取
	if use_cache and _cache.has(path):
		return _cache[path]
	
	# 嘗試載入資源
	var resource = _try_load_resource(path)
	
	# 如果載入失敗，嘗試載入預設資源
	if resource == null:
		push_warning("AssetManager: 無法載入資源 '%s'，使用預設資源" % path)
		resource = _load_default_asset(asset_type)
	
	# 存入快取
	if use_cache and resource != null:
		_cache[path] = resource
	
	return resource

## 載入角色精靈圖
## @param sprite_path: 精靈圖路徑
## @param fallback_paths: fallback路徑列表
## @return 載入的精靈圖資源
func load_character_sprite(sprite_path: String, fallback_paths: Array = []) -> Texture2D:
	# 嘗試載入主要路徑
	var sprite = load_asset(sprite_path, AssetType.SPRITE)
	if sprite != null:
		return sprite
	
	# 嘗試fallback路徑
	for fallback in fallback_paths:
		sprite = load_asset(fallback, AssetType.SPRITE)
		if sprite != null:
			return sprite
	
	# 返回預設精靈圖
	return _load_default_asset(AssetType.SPRITE)

## 載入角色動畫
## @param animation_path: 動畫路徑
## @param fallback_paths: fallback路徑列表
## @return 載入的動畫資源
func load_character_animation(animation_path: String, fallback_paths: Array = []) -> Resource:
	var animation = load_asset(animation_path, AssetType.ANIMATION)
	if animation != null:
		return animation
	
	for fallback in fallback_paths:
		animation = load_asset(fallback, AssetType.ANIMATION)
		if animation != null:
			return animation
	
	return _load_default_asset(AssetType.ANIMATION)

## 載入音效
## @param audio_path: 音效路徑
## @param fallback_paths: fallback路徑列表
## @return 載入的音效資源
func load_audio(audio_path: String, fallback_paths: Array = []) -> AudioStream:
	var audio = load_asset(audio_path, AssetType.AUDIO)
	if audio != null:
		return audio
	
	for fallback in fallback_paths:
		audio = load_asset(fallback, AssetType.AUDIO)
		if audio != null:
			return audio
	
	return _load_default_asset(AssetType.AUDIO)

## 載入特效場景
## @param vfx_path: 特效路徑
## @param fallback_paths: fallback路徑列表
## @return 載入的特效場景
func load_vfx(vfx_path: String, fallback_paths: Array = []) -> PackedScene:
	var vfx = load_asset(vfx_path, AssetType.VFX)
	if vfx != null:
		return vfx
	
	for fallback in fallback_paths:
		vfx = load_asset(fallback, AssetType.VFX)
		if vfx != null:
			return vfx
	
	return _load_default_asset(AssetType.VFX)

## 預載入資源列表
## @param paths: 資源路徑列表
## @param asset_type: 資源類型
func preload_assets(paths: Array, asset_type: AssetType) -> void:
	for path in paths:
		if not path.is_empty():
			load_asset(path, asset_type, true)

## 清除快取
func clear_cache() -> void:
	_cache.clear()

## 清除指定路徑的快取
func clear_cache_path(path: String) -> void:
	if _cache.has(path):
		_cache.erase(path)

## 嘗試載入資源
func _try_load_resource(path: String) -> Resource:
	if not ResourceLoader.exists(path):
		return null
	
	var resource = ResourceLoader.load(path)
	return resource

## 載入預設資源
func _load_default_asset(asset_type: AssetType) -> Resource:
	var default_path = DEFAULT_PATHS.get(asset_type, "")
	if default_path.is_empty():
		return null
	
	# 預設資源不使用快取，避免遞迴
	var resource = _try_load_resource(default_path)
	if resource == null:
		push_error("AssetManager: 無法載入預設資源 '%s'" % default_path)
	
	return resource

## 取得快取大小
func get_cache_size() -> int:
	return _cache.size()

## 檢查資源是否在快取中
func is_cached(path: String) -> bool:
	return _cache.has(path)
