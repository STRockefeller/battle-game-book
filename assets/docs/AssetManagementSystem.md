# 資源管理系統文檔

## 概述

資源管理系統負責載入和管理遊戲中的所有視覺和音頻資源，包括角色精靈圖、動作動畫、音效和特效。系統採用 fallback 機制，當指定資源不存在時會自動使用預設資源，確保遊戲不會因為缺少資源而崩潰。

## 核心組件

### 1. AssetManager（資源管理器）

**位置**: `scripts/AssetManager.gd`

**功能**:
- 統一管理所有遊戲資源的載入
- 支援資源快取，避免重複載入
- 提供 fallback 機制
- 單例模式，全域訪問

**主要方法**:
```gdscript
# 載入單一資源
load_asset(path: String, asset_type: AssetType, use_cache: bool = true) -> Resource

# 載入角色精靈圖（帶 fallback 列表）
load_character_sprite(sprite_path: String, fallback_paths: Array = []) -> Texture2D

# 載入音效
load_audio(audio_path: String, fallback_paths: Array = []) -> AudioStream

# 載入特效場景
load_vfx(vfx_path: String, fallback_paths: Array = []) -> PackedScene

# 預載入資源列表
preload_assets(paths: Array, asset_type: AssetType) -> void

# 清除快取
clear_cache() -> void
```

**使用範例**:
```gdscript
var asset_manager = AssetManager.get_instance()

# 載入角色精靈圖，如果不存在會使用預設資源
var sprite = asset_manager.load_character_sprite("res://assets/sprites/hero/idle.png")

# 載入音效，提供 fallback 路徑
var audio = asset_manager.load_audio(
    "res://assets/audio/hero/attack.ogg",
    ["res://assets/audio/common/attack.ogg"]
)
```

### 2. CharacterVisualState（角色視覺狀態）

**位置**: `scripts/CharacterVisualState.gd`

**功能**:
- 管理角色的視覺狀態（姿勢、生命值、狀態效果）
- 根據狀態組合決定應該顯示的資源
- 支援網路同步的序列化

**姿勢枚舉**:
```gdscript
enum Pose {
    IDLE,      # 待機
    ATTACK,    # 攻擊
    HIT,       # 受擊
    DEFEND,    # 防禦
    CAST,      # 施法
    VICTORY,   # 勝利
    DEFEAT,    # 失敗
    LOW_HP     # 低血量待機
}
```

**主要方法**:
```gdscript
# 更新生命值百分比
update_hp(current_hp: int, max_hp: int) -> void

# 設定姿勢
set_pose(pose: Pose) -> void

# 添加/移除狀態效果
add_status_effect(status_id: String) -> void
remove_status_effect(status_id: String) -> void

# 取得應該顯示的精靈圖路徑（優先級排序）
get_sprite_paths(base_sprite_paths: Dictionary) -> Array[String]

# 取得應該播放的音效路徑
get_audio_paths(base_audio_paths: Dictionary) -> Array[String]

# 取得狀態效果圖示和特效路徑
get_status_icon_paths() -> Array[String]
get_status_vfx_paths() -> Array[String]

# 序列化為字典（用於網路同步）
to_dict() -> Dictionary
static func from_dict(data: Dictionary) -> CharacterVisualState
```

**使用範例**:
```gdscript
# 創建視覺狀態
var visual_state = CharacterVisualState.new("hero")
visual_state.update_hp(50, 100)  # 50%血量
visual_state.set_pose(CharacterVisualState.Pose.ATTACK)

# 取得應該顯示的精靈圖路徑（按優先級）
var sprite_paths = visual_state.get_sprite_paths({
    CharacterVisualState.Pose.IDLE: "res://assets/sprites/hero/idle.png",
    CharacterVisualState.Pose.ATTACK: "res://assets/sprites/hero/attack.png"
})
# 返回: ["res://assets/sprites/hero/attack.png", "res://assets/sprites/hero/idle.png"]
```

### 3. BattleVisualPlayer（戰鬥視覺播放器）

**位置**: `scripts/BattleVisualPlayer.gd`

**功能**:
- 協調播放動畫、音效、特效
- 管理播放序列的生命週期
- 自動清理播放完畢的特效

**信號**:
```gdscript
signal animation_started()
signal animation_finished()
signal sequence_completed()
```

**主要方法**:
```gdscript
# 播放完整的動作序列
play_action_sequence(
    character_sprite: Sprite2D,
    visual_state: CharacterVisualState,
    action_data: Dictionary,
    duration: float = 0.5
) -> void

# 播放受擊序列
play_hit_sequence(
    character_sprite: Sprite2D,
    visual_state: CharacterVisualState,
    hit_vfx_path: String = "",
    duration: float = 0.3
) -> void

# 播放待機動畫
play_idle(character_sprite: Sprite2D, visual_state: CharacterVisualState) -> void

# 播放勝利/失敗動畫
play_victory(character_sprite: Sprite2D, visual_state: CharacterVisualState) -> void
play_defeat(character_sprite: Sprite2D, visual_state: CharacterVisualState) -> void

# 停止當前播放
stop() -> void

# 暫停/恢復播放
pause() -> void
resume() -> void
```

**使用範例**:
```gdscript
var visual_player = BattleVisualPlayer.new()
add_child(visual_player)

# 播放攻擊動作
var action_data = {
    "audio_path": "res://assets/audio/actions/slash_cast.ogg",
    "vfx_path": "res://assets/vfx/actions/slash_cast.tscn"
}

visual_player.play_action_sequence(
    character_sprite,
    visual_state,
    action_data,
    0.6  # 動畫持續0.6秒
)

# 等待動畫完成
await visual_player.animation_finished
```

## 資源路徑規範

### 角色資源

Character 資源（.tres）中定義：

```gdscript
asset_id = "hero"  # 角色資源ID

# 精靈圖
sprite_idle = "res://assets/sprites/hero/idle.png"
sprite_attack = "res://assets/sprites/hero/attack.png"
sprite_hit = "res://assets/sprites/hero/hit.png"
sprite_defend = "res://assets/sprites/hero/defend.png"
sprite_cast = "res://assets/sprites/hero/cast.png"
sprite_victory = "res://assets/sprites/hero/victory.png"
sprite_defeat = "res://assets/sprites/hero/defeat.png"
sprite_low_hp = "res://assets/sprites/hero/idle_low_hp.png"

# 音效
audio_attack = "res://assets/audio/hero/attack.ogg"
audio_hit = "res://assets/audio/hero/hit.ogg"
audio_defend = "res://assets/audio/hero/defend.ogg"
audio_victory = "res://assets/audio/hero/victory.ogg"
audio_defeat = "res://assets/audio/hero/defeat.ogg"
```

### 動作資源

Action 資源（.tres）中定義：

```gdscript
animation_sprite = "res://assets/sprites/actions/hero_slash.png"
audio_cast = "res://assets/audio/actions/slash_cast.ogg"
audio_hit = "res://assets/audio/actions/slash_hit.ogg"
vfx_cast = "res://assets/vfx/actions/slash_cast.tscn"
vfx_hit = "res://assets/vfx/actions/slash_hit.tscn"
animation_duration = 0.6
```

### 狀態效果資源

StatusEffect 資源（.tres）中定義：

```gdscript
icon_path = "res://assets/sprites/status_icons/poison.png"
vfx_path = "res://assets/vfx/status/poison.tscn"
```

## Fallback 機制

資源載入遵循以下優先級：

1. **指定路徑**: 首先嘗試載入指定的資源路徑
2. **Fallback 列表**: 如果失敗，依次嘗試 fallback 路徑列表
3. **預設資源**: 如果所有路徑都失敗，使用預設資源
4. **空值**: 如果連預設資源都不存在，返回 null

預設資源路徑：
- 精靈圖: `res://assets/sprites/default_character.svg`
- 動畫: `res://assets/sprites/default_animation.tres`
- 音效: `res://assets/audio/default_sound.ogg`
- 特效: `res://assets/vfx/default_effect.tscn`

## 整合到 Battle UI

在 `Battle.gd` 中的整合：

```gdscript
# 初始化
var visual_player: BattleVisualPlayer = null
var asset_manager: AssetManager = null
var p1_visual_state: CharacterVisualState = null
var p1_sprite: Sprite2D = null

func _ready():
    _initialize_visual_system()
    # ...

func _initialize_visual_system():
    asset_manager = AssetManager.get_instance()
    visual_player = BattleVisualPlayer.new()
    add_child(visual_player)
    
    # 創建視覺狀態
    p1_visual_state = CharacterVisualState.new(player1.asset_id)
    
    # 創建精靈節點
    p1_sprite = Sprite2D.new()
    add_child(p1_sprite)

# 播放動作
func _on_action_executed(user, target, action, result):
    var action_data = {
        "audio_path": action.audio_cast,
        "vfx_path": action.vfx_cast
    }
    
    visual_player.play_action_sequence(
        user_sprite,
        user_visual_state,
        action_data,
        action.animation_duration
    )
    
    if result["hit"]:
        await get_tree().create_timer(0.5).timeout
        visual_player.play_hit_sequence(
            target_sprite,
            target_visual_state,
            action.vfx_hit
        )
```

## 資源目錄結構

```
assets/
├── sprites/
│   ├── hero/               # 勇者精靈圖
│   ├── elise/              # 艾莉絲精靈圖
│   ├── actions/            # 動作特效精靈圖
│   ├── status_icons/       # 狀態圖示
│   └── default_character.svg  # 預設角色精靈圖
├── audio/
│   ├── hero/               # 勇者音效
│   ├── elise/              # 艾莉絲音效
│   ├── actions/            # 動作音效
│   ├── common/             # 通用音效
│   └── default_sound.ogg   # 預設音效
└── vfx/
    ├── actions/            # 動作特效場景
    ├── status/             # 狀態特效場景
    └── default_effect.tscn # 預設特效
```

## 性能優化

### 資源快取

AssetManager 自動快取載入過的資源：

```gdscript
# 第一次載入（從硬碟）
var sprite1 = asset_manager.load_asset(path, AssetType.SPRITE, true)

# 第二次載入（從快取）
var sprite2 = asset_manager.load_asset(path, AssetType.SPRITE, true)
```

### 資源預載入

在關鍵時刻預載入資源：

```gdscript
# 戰鬥開始前預載入所有資源
var sprite_paths = [
    "res://assets/sprites/hero/idle.png",
    "res://assets/sprites/hero/attack.png",
    # ...
]

asset_manager.preload_assets(sprite_paths, AssetManager.AssetType.SPRITE)
```

### 清理快取

在場景切換時清理快取：

```gdscript
func _exit_tree():
    if asset_manager:
        asset_manager.clear_cache()
```

## 擴展指南

### 添加新的資源類型

1. 在 AssetManager 中添加新的 AssetType 枚舉值
2. 在 DEFAULT_PATHS 中添加預設路徑
3. 實作專門的載入方法（參考 `load_character_sprite`）

### 添加新的角色姿勢

1. 在 CharacterVisualState.Pose 中添加新的枚舉值
2. 在 Character 資源中添加對應的精靈圖欄位
3. 更新 `get_sprite_paths` 方法的邏輯

### 自定義特效場景

特效場景應該：
- 繼承 Node2D
- 播放完畢後自動清理（`queue_free()`）
- 發送 `animation_finished` 信號（可選）

範例特效腳本：
```gdscript
extends Node2D

func _ready():
    var anim_player = $AnimationPlayer
    anim_player.play("effect")
    anim_player.animation_finished.connect(_on_finished)

func _on_finished(_name):
    queue_free()
```

## 故障排除

### 問題：資源載入失敗

**症狀**: 控制台出現 "AssetManager: 無法載入資源" 警告

**解決方案**:
1. 檢查資源路徑是否正確
2. 確認檔案確實存在於指定位置
3. 在 Godot 編輯器中手動重新匯入資源
4. 檢查預設資源是否存在

### 問題：特效不會消失

**症狀**: 特效播放後一直留在場景中

**解決方案**:
1. 確認特效場景有實作自動清理邏輯
2. 檢查 AnimationPlayer 的 `animation_finished` 信號是否正確連接
3. 為粒子效果添加生命週期計時器

### 問題：動畫不同步

**症狀**: 音效和視覺效果播放時機不一致

**解決方案**:
1. 調整 `animation_duration` 參數
2. 使用 `await` 等待特定時間點
3. 檢查 BattleVisualPlayer 的信號連接

## 測試清單

在添加新資源後，測試以下項目：

- [ ] 資源能正確載入並顯示
- [ ] 缺少資源時會使用預設資源
- [ ] 動畫播放完畢後正確清理
- [ ] 音效正確播放且音量適中
- [ ] 特效位置和大小合適
- [ ] 戰鬥日誌正確顯示動作信息
- [ ] 角色狀態更新時視覺正確反映

## 未來擴展

計劃中的功能：

1. **動態資源載入**: 根據關卡動態載入/卸載資源
2. **資源壓縮**: 支援壓縮資源包
3. **本地化支援**: 根據語言載入不同的音效和精靈圖
4. **角色換裝**: 支援角色外觀自定義
5. **特效編輯器**: 內建特效編輯工具
