# 文檔導覽與結構

本專案的文檔分為兩大部分：**遊戲設定**與**開發筆記**。

---

## 📖 遊戲設定文檔

這些文檔定義了遊戲的**實際規則、數值、機制**，是遊戲開發的「聖經」。

### 核心遊戲機制

| 文檔 | 內容 | 用途 |
| :--- | :--- | :--- |
| [`Battle.md`](./Battle.md) | 對戰流程與規則 | 了解一場戰鬥如何進行 |
| [`Character.md`](./Character.md) | 角色屬性與計算公式 | 查詢屬性計算、角色模板 |
| [`Action.md`](./Action.md) | 動作（技能）設計 | 了解動作的核心參數 |
| [`Stance.md`](./Stance.md) | 姿態機制 | 了解姿態系統與優先度 |
| [`StatusEffectSystem.md`](./StatusEffectSystem.md) | 狀態效果系統 | 了解 Buff/Debuff/異常 |

### 系統架構（設計層面）

| 文檔 | 內容 | 用途 |
| :--- | :--- | :--- |
| [`BattleSystemArchitecture.md`](./BattleSystemArchitecture.md) | 對戰系統三層架構 | 理解單機與多人架構 |
| [`AssetManagementSystem.md`](./AssetManagementSystem.md) | 資源管理系統設計 | 了解精靈圖、音效、特效 |
| [`AISystem.md`](./AISystem.md) | AI 系統設計與資源化方案 | 了解 AI 架構與升級路徑 |

### 故事設定

| 文檔 | 內容 | 用途 |
| :--- | :--- | :--- |
| [`Story.md`](./Story.md) | 世界觀與角色背景 | 了解遊戲故事線與世界觀 |

---

## 🔧 開發筆記文檔

這些文檔記錄了**實現進度、技術決策、開發決策**，是團隊協作的參考。

### 統合開發報告

| 文檔 | 內容 | 查看時機 |
| :--- | :--- | :--- |
| [`DEVELOPMENT_NOTES.md`](./DEVELOPMENT_NOTES.md) | 所有系統的實現進度與決策 | 新人上手時、評估工作量時 |

包含:
- 對戰系統重構完成報告（2025-12-08）
- AI 系統實現完成報告（2025-12-08）
- 資源管理系統實作報告（2025-12-08）
- 系統實現方針確認（2025-12-08）
- 完整對戰流程實現報告（2025-12-08）

---

## 📋 文檔對照表

### 快速查找

**我想了解...**

| 需求 | 參考文檔 |
| :--- | :--- |
| 角色屬性如何計算 | [`Character.md`](./Character.md) |
| 傷害如何計算 | [`Character.md`](./Character.md#戰鬥計算) + [`BattleLogic`](./BattleSystemArchitecture.md) |
| 動作有哪些參數 | [`Action.md`](./Action.md) |
| 姿態如何影響遊戲 | [`Stance.md`](./Stance.md) |
| 狀態效果（中毒、虛弱等）如何工作 | [`StatusEffectSystem.md`](./StatusEffectSystem.md) |
| 一場戰鬥的流程 | [`Battle.md`](./Battle.md) |
| 系統架構如何設計 | [`BattleSystemArchitecture.md`](./BattleSystemArchitecture.md) |
| 資源（精靈圖、音效、特效）如何加載 | [`AssetManagementSystem.md`](./AssetManagementSystem.md) |
| AI 如何工作 | [`AISystem.md`](./AISystem.md) |
| 實現進度與決策 | [`DEVELOPMENT_NOTES.md`](./DEVELOPMENT_NOTES.md) |
| 故事與世界觀 | [`Story.md`](./Story.md) |

---

## 🎮 新手快速上手

### 第一步：了解遊戲機制
1. 閱讀 [`Battle.md`](./Battle.md) - 了解一場戰鬥的流程
2. 閱讀 [`Character.md`](./Character.md) - 了解角色屬性

### 第二步：了解系統實現
1. 閱讀 [`BattleSystemArchitecture.md`](./BattleSystemArchitecture.md) - 理解三層架構
2. 閱讀 [`DEVELOPMENT_NOTES.md`](./DEVELOPMENT_NOTES.md#對戰系統重構) - 了解已實現功能

### 第三步：了解 AI 系統
1. 閱讀 [`AISystem.md`](./AISystem.md) - 理解 AI 設計
2. 閱讀 [`DEVELOPMENT_NOTES.md`](./DEVELOPMENT_NOTES.md#ai-系統實現) - 了解 4 種 AI 實現

### 第四步：了解資源管理
1. 閱讀 [`AssetManagementSystem.md`](./AssetManagementSystem.md) - 理解資源加載
2. 查看 `assets/sprites/README.md` - 了解如何添加精靈圖
3. 查看 `assets/audio/README.md` - 了解如何添加音效

---

## 📁 文檔結構

```
assets/docs/
│
├── 遊戲設定（規則與數值）
│   ├── Battle.md                      # 對戰流程
│   ├── Character.md                   # 角色屬性
│   ├── Action.md                      # 動作設計
│   ├── Stance.md                      # 姿態系統
│   └── StatusEffectSystem.md          # 狀態效果
│
├── 系統架構（設計層面）
│   ├── BattleSystemArchitecture.md    # 對戰系統架構
│   ├── AssetManagementSystem.md       # 資源管理
│   └── AISystem.md                    # AI 系統
│
├── 開發筆記（進度與決策）
│   └── DEVELOPMENT_NOTES.md           # 統合實現報告
│
├── 故事設定
│   └── Story.md                       # 世界觀與角色
│
└── 導覽（本文檔）
    └── INDEX.md
```

---

## 🔗 文檔交叉參考

### 對戰流程相關
- [`Battle.md`](./Battle.md) → 定義流程
- [`BattleSystemArchitecture.md`](./BattleSystemArchitecture.md) → 三層架構實現
- [`Character.md`](./Character.md) → 屬性計算
- [`Action.md`](./Action.md) → 動作參數
- [`Stance.md`](./Stance.md) → 姿態機制

### AI 相關
- [`AISystem.md`](./AISystem.md) → 設計方案
- [`DEVELOPMENT_NOTES.md`](./DEVELOPMENT_NOTES.md#ai-系統實現) → 實現進度

### 資源管理相關
- [`AssetManagementSystem.md`](./AssetManagementSystem.md) → 設計方案
- [`DEVELOPMENT_NOTES.md`](./DEVELOPMENT_NOTES.md#資源管理系統) → 實現進度
- `assets/sprites/README.md` → 精靈圖指南
- `assets/audio/README.md` → 音效指南
- `assets/vfx/README.md` → 特效指南

---

## ⚠️ 編寫新文檔的注意事項

### 遊戲設定文檔（放在這裡）
- 包含實際的遊戲規則、數值、公式
- 例如：「傷害計算公式」、「角色屬性」、「姿態效果」
- 這些內容應該**盡可能穩定**，修改時要謹慎

### 開發筆記文檔（都放在 DEVELOPMENT_NOTES.md）
- 包含實現進度、技術決策、解決方案
- 例如：「我們選擇三層架構因為...」、「AI 系統已實現 4 種...」
- 這些內容可以**頻繁更新**，記錄決策過程

### 禁止混雜
❌ **不要**在 `Battle.md` 中說「我們決定採用 ServerBattleManager」  
✅ **應該**在 `DEVELOPMENT_NOTES.md` 中說這些決策  

❌ **不要**在 `DEVELOPMENT_NOTES.md` 中說「傷害公式是 ATK × 倍率」  
✅ **應該**在 `Character.md` 中說這些規則

---

## 📝 更新日誌

### 2025-12-10
- 新增 `DEVELOPMENT_NOTES.md` - 統合所有實現報告
- 新增 `INDEX.md` - 文檔導覽與結構說明
- 整理文檔結構，分離遊戲設定與開發筆記
- 刪除重複內容，添加交叉參考

---

## 聯絡與反饋

如有文檔結構建議或發現不一致之處，歡迎指正！
