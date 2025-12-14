# 戰鬥遊戲書 - 文檔導覽

本專案的文檔集中在 `assets/docs/` 目錄中，分為兩大類別：**遊戲機制設計**和**開發參考**。

---

## 📖 遊戲機制設計文檔

> **用途：** 定義遊戲的實際規則、數值、機制。這是遊戲設計的「聖經」。  
> **更新頻率：** 低。修改時需要謹慎考慮對整體平衡的影響。  
> **讀者：** 企劃、設計師、數值策劃、開發人員

### 核心戰鬥機制

| 文檔 | 說明 |
| :--- | :--- |
| [`Battle.md`](./Battle.md) | 對戰流程與回合制規則 |
| [`Character.md`](./Character.md) | 角色屬性與計算公式 |
| [`Action.md`](./Action.md) | 動作（技能）系統 |
| [`Stance.md`](./Stance.md) | 姿態機制 |
| [`StatusEffectSystem.md`](./StatusEffectSystem.md) | 狀態效果系統（Buff/Debuff） |

### 進階系統

| 文檔 | 說明 |
| :--- | :--- |
| [`PassiveTrait.md`](./PassiveTrait.md) | 被動特質系統 |
| [`DivineFavor.md`](./DivineFavor.md) | 神恩系統 |

### 故事與世界觀

| 文檔 | 說明 |
| :--- | :--- |
| [`Story.md`](./Story.md) | 世界觀與角色背景 |
| [`EliseCharacter.md`](./EliseCharacter.md) | 艾莉絲角色設定 |

---

## 🔧 開發參考文檔

> **用途：** 記錄系統架構、實現細節、技術決策、開發進度。  
> **更新頻率：** 高。隨開發進度持續更新。  
> **讀者：** 開發人員、技術 PM、新加入的團隊成員

| 文檔 | 說明 |
| :--- | :--- |
| [`DEVELOPMENT_NOTES.md`](./DEVELOPMENT_NOTES.md) | **統合開發報告** - 所有系統的實現進度、技術決策、開發時間線 |
| [`BattleSystemArchitecture.md`](./BattleSystemArchitecture.md) | 對戰系統三層架構設計 |
| [`AssetManagementSystem.md`](./AssetManagementSystem.md) | 資源管理系統（精靈圖、音效、特效） |
| [`AISystem.md`](./AISystem.md) | AI 系統設計與實現 |

---

## 📋 快速查找表

**我想了解...**

| 問題 | 參考文檔 |
| :--- | :--- |
| 角色屬性如何計算？ | [`Character.md`](./Character.md) |
| 傷害如何計算？ | [`Character.md`](./Character.md) + [`BattleSystemArchitecture.md`](./BattleSystemArchitecture.md) |
| 技能有哪些參數？ | [`Action.md`](./Action.md) |
| 姿態如何影響戰鬥？ | [`Stance.md`](./Stance.md) |
| 狀態效果（中毒、虛弱）如何工作？ | [`StatusEffectSystem.md`](./StatusEffectSystem.md) |
| 一場戰鬥的完整流程？ | [`Battle.md`](./Battle.md) + [`BattleSystemArchitecture.md`](./BattleSystemArchitecture.md) |
| 被動特質系統如何運作？ | [`PassiveTrait.md`](./PassiveTrait.md) |
| 神恩系統如何設計？ | [`DivineFavor.md`](./DivineFavor.md) |
| 系統架構如何設計？ | [`BattleSystemArchitecture.md`](./BattleSystemArchitecture.md) |
| 資源（圖片、音效）如何加載？ | [`AssetManagementSystem.md`](./AssetManagementSystem.md) |
| AI 如何決策？ | [`AISystem.md`](./AISystem.md) |
| 開發進度和已完成功能？ | [`DEVELOPMENT_NOTES.md`](./DEVELOPMENT_NOTES.md) |

---

## 🎮 新手快速上手路徑

### 路徑 A：我是企劃/設計師（關注遊戲機制）

1. **理解核心戰鬥** → [`Battle.md`](./Battle.md)
2. **掌握角色屬性** → [`Character.md`](./Character.md)
3. **設計技能** → [`Action.md`](./Action.md)
4. **了解進階系統** → [`PassiveTrait.md`](./PassiveTrait.md) + [`DivineFavor.md`](./DivineFavor.md)

### 路徑 B：我是開發者（關注代碼實現）

1. **理解架構** → [`BattleSystemArchitecture.md`](./BattleSystemArchitecture.md)
2. **查看實現進度** → [`DEVELOPMENT_NOTES.md`](./DEVELOPMENT_NOTES.md)
3. **理解 AI 邏輯** → [`AISystem.md`](./AISystem.md)
4. **處理資源加載** → [`AssetManagementSystem.md`](./AssetManagementSystem.md)

### 路徑 C：我要修改現有功能

1. **查看機制定義** → 對應的遊戲機制設計文檔（確認規則）
2. **查看實現方式** → [`DEVELOPMENT_NOTES.md`](./DEVELOPMENT_NOTES.md)（找到代碼位置和技術細節）

---

## 📁 完整文檔結構

```
assets/docs/
│
├── 【遊戲機制設計】
│   ├── Battle.md                      # 對戰流程
│   ├── Character.md                   # 角色屬性
│   ├── Action.md                      # 技能系統
│   ├── Stance.md                      # 姿態機制
│   ├── StatusEffectSystem.md          # 狀態效果
│   ├── PassiveTrait.md                # 被動特質
│   ├── DivineFavor.md                 # 神恩系統
│   ├── Story.md                       # 世界觀
│   └── EliseCharacter.md              # 角色設定
│
└── 【開發參考】
    ├── DEVELOPMENT_NOTES.md           # 統合開發報告（含所有實現細節）
    ├── BattleSystemArchitecture.md    # 系統架構
    ├── AssetManagementSystem.md       # 資源管理
    └── AISystem.md                    # AI 系統
```

---

## ⚠️ 編寫文檔的規範

### 【遊戲機制設計】文檔

✅ **應該包含：**
- 遊戲規則、數值、公式
- 機制的「是什麼」和「為什麼這樣設計」
- 舉例說明玩家體驗
- 平衡性考量

❌ **不應該包含：**
- 代碼實現細節（如「使用 BattleLogic.calculate_damage()」）
- 技術決策（如「我們選擇三層架構因為...」）
- 開發進度（如「已完成 80%」）

### 【開發參考】文檔

✅ **應該包含：**
- 系統架構圖、類別關係
- 代碼範例、API 說明
- 技術決策理由與權衡
- 實現進度、已知問題

❌ **不應該包含：**
- 遊戲平衡數值（如「傷害公式是 ATK × 1.5」）
- 遊戲規則說明（如「姿態會影響可用技能」）

---

## 📝 更新日誌

### 2025-12-14
- 文檔結構重整：文件名使用英文，內文使用繁體中文
- 刪除完成報告、變更總結等低價值文檔
- 開發參考統一集中在 DEVELOPMENT_NOTES.md
- 簡化文檔分類，提升可讀性

### 2025-12-10
- 新增 DEVELOPMENT_NOTES.md 統合開發報告
- 新增 INDEX.md 文檔導覽
- 分離遊戲設定與開發筆記
