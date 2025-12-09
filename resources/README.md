# Resources 資源結構說明

## 目錄結構

```
resources/
├── actions/          # 所有動作資源
│   ├── Common*.tres      # 通用動作（多角色共用）
│   ├── Hero*.tres        # 勇者專屬動作
│   └── Elise*.tres       # 艾莉絲專屬動作
├── characters/       # 角色資源
│   ├── Hero.tres         # 勇者
│   ├── Elise.tres        # 艾莉絲
│   └── *Story.tres       # 角色劇情配置
├── statuses/         # 狀態效果資源
│   ├── Burning.tres
│   ├── Poison.tres
│   ├── Weakness.tres
│   └── ...
```

## 命名規範

### Actions（動作）
- **通用動作**: `Common[Name].tres`
  - 例如: `CommonGuard.tres`, `CommonStandUp.tres`, `CommonRest.tres`
  - 用於多個角色共用的基礎動作

- **角色專屬**: `[CharacterName][ActionName].tres`
  - 例如: `HeroSlash.tres`, `EliseVineLash.tres`
  - 角色名稱使用大駝峰命名

### Characters（角色）
- **主檔案**: `[CharacterName].tres`
  - 例如: `Hero.tres`, `Elise.tres`

- **劇情配置**: `[CharacterName]Story.tres`
  - 例如: `EliseStory.tres`

### Statuses（狀態效果）
- **命名**: `[EffectName].tres`
  - 例如: `Burning.tres`, `Poison.tres`
  - 使用大駝峰命名

## 建議改進

### 1. 新增資料夾（未來規劃）

#### `resources/ai/`
AI 行為資源化，便於配置不同 AI 策略。詳見下方 AI 資源化設計建議。

**注意**：Stance 系統採用程式碼寫死方式（枚舉 + 狀態機），不會資源化。

### 2. 角色分類

當角色數量增多時，建議按類型分類：

```
resources/characters/
├── heroes/           # 英雄角色
│   ├── Hero.tres
│   └── ...
├── enemies/          # 敵人角色
│   ├── Goblin.tres
│   └── ...
└── npcs/            # NPC 角色
	└── ...
```

### 3. 動作分類

當動作數量增多時，建議按類型分類：

```
resources/actions/
├── common/          # 通用動作
│   ├── CommonGuard.tres
│   └── ...
├── hero/            # 勇者動作
│   ├── HeroSlash.tres
│   └── ...
└── elise/           # 艾莉絲動作
	├── EliseVineLash.tres
	└── ...
```

### 4. 狀態效果分類

```
resources/statuses/
├── debuffs/         # 減益效果
│   ├── Poison.tres
│   ├── Weakness.tres
│   └── ...
├── buffs/           # 增益效果
│   ├── Regen.tres
│   └── ...
└── control/         # 控制效果
	├── Knockdown.tres
	└── ...
```

## 資源 ID 命名規範

### Action ID
- 格式: `[character]_[action_name]`
- 例如: `hero_slash`, `elise_vine_lash`, `common_guard`

### Status ID
- 格式: `[effect_name]`
- 例如: `poison`, `burning`, `weakness`

## 維護建議

1. **版本控制**: 重要資源變更時記錄版本號
2. **文檔**: 在 `assets/docs/` 中維護對應的設計文檔
3. **測試**: 為每個新增的動作/狀態創建測試用例
4. **備份**: 定期備份資源檔案

## 相關文件

- `/assets/docs/Action.md` - 動作系統設計文檔
- `/assets/docs/Character.md` - 角色系統設計文檔
- `/assets/docs/StatusEffectSystem.md` - 狀態效果系統文檔
- `/assets/docs/Stance.md` - 姿態系統文檔
- `/assets/docs/AISystem.md` - AI 系統設計與資源化建議 ⭐
