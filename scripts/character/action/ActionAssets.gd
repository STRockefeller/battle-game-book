extends Resource
class_name ActionAssets

## 動作視覺資源定義
## 包含動作的精靈圖、音效和特效路徑
## 每個動作應該有一個對應的 ActionAssets.tres 資源檔（或在Action.tres中關聯）

# --- 精靈圖資源 ---
@export_group("Visual Assets")
@export var animation_sprite: String = ""  # 動作執行時的精靈圖

# --- 音效資源 ---
@export_group("Audio Assets")
@export var audio_cast: String = ""  # 施放時的音效
@export var audio_hit: String = ""   # 命中時的音效

# --- 特效資源 ---
@export_group("VFX Assets")
@export var vfx_cast: String = ""    # 施放時的特效
@export var vfx_hit: String = ""     # 命中時的特效

# --- 動畫時長 ---
@export_group("Animation")
@export var animation_duration: float = 0.5  # 動畫持續時間（秒）

## 取得所有資源路徑（用於預載入）
func get_all_paths() -> Array[String]:
	var paths: Array[String] = []
	if not animation_sprite.is_empty():
		paths.append(animation_sprite)
	if not audio_cast.is_empty():
		paths.append(audio_cast)
	if not audio_hit.is_empty():
		paths.append(audio_hit)
	if not vfx_cast.is_empty():
		paths.append(vfx_cast)
	if not vfx_hit.is_empty():
		paths.append(vfx_hit)
	return paths
