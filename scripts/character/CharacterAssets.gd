extends Resource
class_name CharacterAssets

## 角色視覺資源定義
## 包含角色的所有精靈圖和音效路徑
## 每個角色應該有一個對應的 CharacterAssets.tres 資源檔

# --- 精靈圖資源 ---
@export_group("Sprites")
@export var sprite_idle: String = "res://assets/sprites/characters/no_face/portrait_nb.png"
@export var sprite_attack: String = ""
@export var sprite_hit: String = ""
@export var sprite_defend: String = ""
@export var sprite_cast: String = ""
@export var sprite_victory: String = ""
@export var sprite_defeat: String = ""
@export var sprite_low_hp: String = ""

@export var sprite_selection: String = "res://assets/sprites/characters/no_face/selection.png"

# --- 縮放設定 ---
@export_group("Scale")
@export var auto_scale_enabled: bool = true
@export var target_sprite_height: float = 200.0  # 目標高度（像素）

# --- 音效資源 ---
@export_group("Audio")
@export var audio_attack: String = ""
@export var audio_hit: String = ""
@export var audio_defend: String = ""
@export var audio_victory: String = ""
@export var audio_defeat: String = ""

## 取得指定姿勢的精靈圖路徑
func get_sprite_path(pose: CharacterVisualState.Pose) -> String:
	match pose:
		CharacterVisualState.Pose.IDLE:
			return sprite_idle
		CharacterVisualState.Pose.ATTACK:
			return sprite_attack
		CharacterVisualState.Pose.HIT:
			return sprite_hit
		CharacterVisualState.Pose.DEFEND:
			return sprite_defend
		CharacterVisualState.Pose.CAST:
			return sprite_cast
		CharacterVisualState.Pose.VICTORY:
			return sprite_victory
		CharacterVisualState.Pose.DEFEAT:
			return sprite_defeat
		CharacterVisualState.Pose.LOW_HP:
			return sprite_low_hp
		_:
			return sprite_idle

## 取得所有精靈圖路徑（用於預載入）
func get_all_sprite_paths() -> Array[String]:
	var paths: Array[String] = []
	if not sprite_idle.is_empty():
		paths.append(sprite_idle)
	if not sprite_attack.is_empty():
		paths.append(sprite_attack)
	if not sprite_hit.is_empty():
		paths.append(sprite_hit)
	if not sprite_defend.is_empty():
		paths.append(sprite_defend)
	if not sprite_cast.is_empty():
		paths.append(sprite_cast)
	if not sprite_victory.is_empty():
		paths.append(sprite_victory)
	if not sprite_defeat.is_empty():
		paths.append(sprite_defeat)
	if not sprite_low_hp.is_empty():
		paths.append(sprite_low_hp)
	return paths

## 取得所有音效路徑（用於預載入）
func get_all_audio_paths() -> Array[String]:
	var paths: Array[String] = []
	if not audio_attack.is_empty():
		paths.append(audio_attack)
	if not audio_hit.is_empty():
		paths.append(audio_hit)
	if not audio_defend.is_empty():
		paths.append(audio_defend)
	if not audio_victory.is_empty():
		paths.append(audio_victory)
	if not audio_defeat.is_empty():
		paths.append(audio_defeat)
	return paths
