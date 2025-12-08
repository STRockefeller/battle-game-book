# 特效（VFX）資源目錄

此目錄包含遊戲中所有的視覺特效場景。

## 目錄結構

### actions/
動作特效場景：
- `slash_cast.tscn` - 斬擊施放特效
- `slash_hit.tscn` - 斬擊命中特效
- `vine_cast.tscn` - 藤蔓施放特效
- `vine_hit.tscn` - 藤蔓命中特效
- `guard.tscn` - 防禦特效
- `hit_default.tscn` - 預設受擊特效

### status/
狀態效果持續特效：
- `poison.tscn` - 中毒特效（持續顯示在角色身上）
- `burning.tscn` - 燃燒特效
- `weakness.tscn` - 虛弱特效

## 特效場景結構

每個特效場景應該包含：
1. **根節點**：Node2D 或 CPUParticles2D
2. **動畫播放器**（可選）：AnimationPlayer
3. **自動清理**：特效播放完畢後自動釋放

### 範例特效場景結構：

```
hit_effect.tscn
├── Node2D (根節點)
│   ├── CPUParticles2D (粒子效果)
│   ├── Sprite2D (精靈動畫)
│   └── AnimationPlayer
│       └── "play" 動畫
└── Script: 播放完畢後 queue_free()
```

## 建議實作方式

### 簡單特效（精靈動畫）

```gdscript
extends Node2D

@onready var anim_player = $AnimationPlayer

func _ready():
    anim_player.play("effect")
    anim_player.animation_finished.connect(_on_animation_finished)

func _on_animation_finished(_anim_name):
    queue_free()
```

### 粒子特效

```gdscript
extends CPUParticles2D

func _ready():
    emitting = true
    # 等待粒子生命週期結束後清理
    await get_tree().create_timer(lifetime + 0.5).timeout
    queue_free()
```

## 預設資源

如果某個特效不存在，AssetManager會自動使用預設資源：
- `default_effect.tscn` - 預設特效場景

## 快速開始

1. 在 Godot 中創建新的場景（Node2D 根節點）
2. 添加粒子系統或精靈動畫
3. 添加自動清理腳本
4. 儲存為 .tscn 檔案到對應資料夾
5. 在遊戲中測試

## 特效資源來源

- [Godot Particle Editor](https://godotengine.org/) - 內建粒子編輯器
- [OpenGameArt.org](https://opengameart.org/)
- [Itch.io VFX Assets](https://itch.io/game-assets/tag-vfx)

## 提示

- 使用 CPUParticles2D 而非 GPUParticles2D 以獲得更好的 2D 相容性
- 特效持續時間建議在 0.3 到 1.5 秒之間
- 使用 modulate 屬性調整特效顏色以配合角色/動作
- 狀態特效應該是循環動畫，不自動清理
