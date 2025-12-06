# Elise 角色實現文檔

## 概覽

**艾莉絲（Elise）** 是遊戲中的第一個官方可玩角色，定位為 **森林精靈守護者**。她是一個平衡型的魔法輸出角色，擅長控制和支援。

---

## 角色屬性

基礎屬性（總點數：25）：
- **力量 (STR)**: 8
- **智力 (INT)**: 12
- **敏捷 (AGI)**: 10
- **體質 (CON)**: 9
- **幸運 (LUK)**: 6

### 計算的戰鬥屬性

| 屬性 | 公式 | 數值 |
| :--- | :--- | :--- |
| **生命值 (HP)** | CON × 20 | 180 |
| **魔法值 (MP)** | INT × 15 | 180 |
| **物理攻擊力 (ATK)** | STR × 2 | 16 |
| **魔法攻擊力 (MATK)** | INT × 2 | 24 |
| **物理防禦力 (DEF)** | CON × 2 | 18 |
| **魔法防禦力 (MDEF)** | INT × 2 | 24 |
| **準確度 (ACC)** | AGI × 2 | 20 |
| **迴避率 (EVA)** | AGI × 2 + LUK | 26 |
| **暴擊率 (CRT)** | LUK × 1 + AGI × 0.5 | 11% |
| **最大耐力 (STA)** | CON × 8 | 72 |

### 屬性分析

Elise 是一個高智力、高敏捷的魔法型角色：
- **魔法攻擊 (24)** 遠高於物理攻擊 (16)，定位為主要輸出者
- **魔法防禦 (24)** 與魔法攻擊相同，防禦能力不錯
- **敏捷 (10)** 保證了良好的命中率和閃避
- **體質 (9)** 提供 180 HP，足以承受一定傷害

---

## 技能系統

### 1. 藤蔓鞭打 (Vine Lash)

**類型**: 近距離物理 + 自然魔法混合攻擊

```
ID: vine_lash
名稱: 藤蔓鞭打
描述: 用生長的藤蔓抽打敵人，造成自然傷害
消耗: 8 STA + 5 MP
優先度: 1
冷卻: 0 回合
傷害倍率: 1.3
基礎傷害: 14
命中修正: +0.2
暴擊修正: +0.5
標籤: [nature, physical]
```

**特點**: 命中率和暴擊率都很高，是主要的單體輸出技能

---

### 2. 精靈箭術 (Elven Arrow)

**類型**: 遠程精準攻擊

```
ID: elven_arrow
名稱: 精靈箭術
描述: 射出帶有魔力的箭矢，遠距離精準攻擊
消耗: 6 STA + 10 MP
優先度: 2
冷卻: 0 回合
傷害倍率: 1.1
基礎傷害: 10
命中修正: +0.5
暴擊修正: +1.0
標籤: [nature, ranged, physical]
```

**特點**: 命中率最高（+0.5），暴擊率翻倍（+1.0），是精準輸出的首選

---

### 3. 自然治癒 (Nature Heal)

**類型**: 支援 / 治療

```
ID: nature_heal
名稱: 自然治癒
描述: 調動自然力量，恢復友方的生命值
消耗: 10 STA + 20 MP
優先度: 3
冷卻: 1 回合
詠唱時間: 1 回合
傷害倍率: 0.0
標籤: [nature, healing, support]
```

**特點**: 需要1回合詠唱，提供群體治療能力，是團隊的生命線

---

### 4. 召喚藤蔓 (Summon Vines)

**類型**: 控制 / 群體

```
ID: summon_vines
名稱: 召喚藤蔓
描述: 召喚強大的藤蔓困束敵人，限制其行動
消耗: 12 STA + 15 MP
優先度: 2
冷卻: 2 回合
詠唱時間: 1 回合
傷害倍率: 0.8
基礎傷害: 8
命中修正: +0.1
標籤: [nature, control, magic]
```

**特點**: 高耐力成本，用於群體控制，冷卻2回合保証平衡

---

### 5. 森林祝福 (Forest Blessing) - 絕招

**類型**: 大絕招 / 增益

```
ID: forest_blessing
名稱: 森林祝福
描述: 大絕招：與森林融為一體，大幅提升攻擊和防禦
消耗: 20 STA + 30 MP
優先度: 4
冷卻: 3 回合
詠唱時間: 2 回合
傷害倍率: 2.0
基礎傷害: 20
標籤: [nature, ultimate, buff]
```

**特點**: 需要2回合詠唱，傷害倍率翻倍，戰略性大招

---

## 故事系統

### 故鄉信息

- **故鄉名稱**: 翠綠之森 (Evergreen Woods)
- **描述**: 精靈族世代居住的神聖森林，自然魔法匯聚之地

### 災變信息

- **災變名稱**: 魔法失控與森林枯萎
- **嚴重程度**: 0.8 / 1.0（極其嚴重）
- **初始進度**: 60%（已經惡化到相當嚴重的程度）
- **描述**: 魔法失控導致森林枯萎，怪獸從裂縫中湧現，精靈族瀕臨滅絕

### 特殊機制

**森林恢復**: 每場戰鬥表現優異，森林會恢復生機，精靈族得以反擊怪物

- 能量獲得加成: 1.2x（表現好時額外獲得20%能量）
- 完全拯救所需能量: 500

### 故事節點

1. **遭遇第一隻怪獸** (0 能量)
   - 描述: 一隻被魔法腐蝕的野獸從裂縫中出現
   - 災變進度變化: -5%

2. **拯救受傷的精靈** (50 能量)
   - 描述: 發現一名被怪獸攻擊的同族精靈
   - 災變進度變化: -10%

3. **淨化被汙染的聖林** (150 能量)
   - 描述: 進入森林核心，與邪惡力量對抗
   - 災變進度變化: -15%

4. **恢復自然平衡** (300 能量)
   - 描述: 調和自然魔法，開始扭轉局勢
   - 災變進度變化: -20%

5. **面對源界的啟示** (500 能量)
   - 描述: 揭露真相，決定故鄉的最終命運
   - 災變進度變化: -50% (自動達成結局)

### 多重結局

| 災變進度 | 結局類型 | 描述 |
| :--- | :--- | :--- |
| **≤ 0%** | 真結局 (TRUE) | 森林重獲生機，怪獸被完全消滅。精靈族在你的保護下得以延續，並見證了一個全新的時代的開始。 |
| **0% ~ 30%** | 中立結局 (NORMAL) | 雖然災難被緩解，但森林仍未完全恢復。精靈族活了下來，卻永遠失去了故鄉的一部分。 |
| **30% ~ 80%** | 悲劇結局 (BAD) | 森林最終消亡，精靈族逐漸凋零。你倖存下來，卻無法改變這個絕望的結局。 |
| **> 80%** | 隱藏結局 (SECRET) | 通過一切的戰鬥，你發現了源界能量失衡的真正原因——一個黑暗的祕密正在源界的深處醞釀... |

---

## 資源文件位置

| 文件 | 路徑 |
| :--- | :--- |
| 角色屬性 | `resources/characters/Elise.tres` |
| 故事數據 | `resources/characters/EliseStory.tres` |
| 技能1 - 藤蔓鞭打 | `resources/moves/EliseVineLash.tres` |
| 技能2 - 精靈箭術 | `resources/moves/EliseElvenArrow.tres` |
| 技能3 - 自然治癒 | `resources/moves/EliseNatureHeal.tres` |
| 技能4 - 召喚藤蔓 | `resources/moves/EliseSummonVines.tres` |
| 技能5 - 森林祝福 | `resources/moves/EliseForestBlessing.tres` |
| 故事邏輯 | `scripts/story/EliseStory.gd` |

---

## 使用示例

### 在代碼中加載 Elise

```gdscript
# 加載角色資源
var elise = load("res://resources/characters/Elise.tres") as Character
elise.name = "艾莉絲"

# 加載故事數據
var elise_story = load("res://resources/characters/EliseStory.tres") as EliseStory

# 加載技能
var vine_lash = load("res://resources/moves/EliseVineLash.tres") as Action
var elven_arrow = load("res://resources/moves/EliseElvenArrow.tres") as Action
var nature_heal = load("res://resources/moves/EliseNatureHeal.tres") as Action
var summon_vines = load("res://resources/moves/EliseSummonVines.tres") as Action
var forest_blessing = load("res://resources/moves/EliseForestBlessing.tres") as Action

# 設置技能
elise.available_actions = [vine_lash, elven_arrow, nature_heal, summon_vines, forest_blessing]

# 計算故鄉災變進度
var total_energy = 250
var calamity_progress = elise_story.calculate_calamity_progress(total_energy)
# calamity_progress = 0.6 - (250/500) = 0.1 (災難進度下降到10%)

# 判定結局
var ending = elise_story.get_ending_type(calamity_progress)
# ending = "true_ending" (因為進度 ≤ 0%)
```

---

## 設計亮點

1. **平衡的屬性配置**: 高魔法輸出，良好防禦，充足HP
2. **多樣化的技能組合**: 輸出、治療、控制、支援全覆蓋
3. **故事深度**: 多重結局系統，玩家選擇影響故鄉命運
4. **角色特性**: 「森林恢復」機制增強了故事代入感
5. **教學價值**: 作為第一個角色，完整展示遊戲系統

---

## 後續擴展建議

- [ ] 新增 Elise 的立繪和動畫資源
- [ ] 實現戰鬥中的視覺效果（藤蔓生長、治療光芒等）
- [ ] 編寫完整的故事劇情腳本
- [ ] 設計配套的敵人和BOSS戰
- [ ] 實現「森林恢復」機制的具體遊戲邏輯
