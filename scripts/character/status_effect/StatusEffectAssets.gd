extends Resource
class_name StatusEffectAssets

## 狀態效果視覺資源定義
## 包含狀態效果的圖示和特效路徑

# --- 視覺資源 ---
@export_group("Visual Assets")
@export var icon_path: String = ""     # 狀態圖示
@export var vfx_path: String = ""      # 狀態特效（持續在角色身上）

## 取得所有資源路徑（用於預載入）
func get_all_paths() -> Array[String]:
	var paths: Array[String] = []
	if not icon_path.is_empty():
		paths.append(icon_path)
	if not vfx_path.is_empty():
		paths.append(vfx_path)
	return paths
