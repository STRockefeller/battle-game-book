# Action 遷移計劃

## 遷移總覽

需要遷移 19 個 .tres Action 檔案到新的積木系統。

### 轉換規則

1. **屬性映射**:
   - `power` * `damage_multiplier` → `damage`
   - `accuracy_modifier` (加成百分比) → `accuracy` (基礎 100.0)
   - `critical_modifier` (加成百分比) → `critical_rate` (基礎 0.0)
   - 移除過時欄位: `cast_time`, `applicable_ranges`, `out_of_range_penalty`

2. **效果積木**:
   - 若 `damage > 0` → 添加 `DamageEffect` 
   - 若 `user_stance_change_enabled` → 添加 `StanceEffect` (USER)
   - 若 `target_stance_change_enabled` → 添加 `StanceEffect` (TARGET)
   - 若有 `effects_on_hit` → 檢查是否需要特殊處理

3. **特殊情況**:
   - `healing` 標籤 + `power > 0` → 需要實現 `HealEffect` (目前用 DamageEffect 負數代替或 StatusEffect)
   - `rest` 標籤 → 在 BattleManager 特殊處理，無需積木

## 遷移檢查清單

### 攻擊類動作
- [ ] CommonBasicAttack (power=5, 無倍率)
- [ ] CyrusSwordStrike (power=15, 倍率 1.2)
- [ ] EliseVineLash (power=14, 倍率 1.3)
- [ ] RagLavaPunch (power=18, 倍率 1.4)
- [ ] RagEarthQuake (power=20, 倍率 1.5)
- [ ] MinaDreamErosion (power=12, 倍率 1.1)
- [ ] SaraAlchemyBomb (power=16, 倍率 1.3)

### 防禦/支援類動作
- [ ] CommonGuard (user_stance=3/GUARD)
- [ ] CommonRest (特殊標籤)
- [ ] CommonStandUp (user_stance=0/STANDING)
- [ ] CyrusRoyalCommand (?)
- [ ] CyrusLightBarrier (?)
- [ ] RagRockShield (user_stance=3/GUARD ?)
- [ ] EliseNatureHeal (healing, power=30)
- [ ] SaraEnergyRepair (healing ?)
- [ ] MinaHypnosis (特殊效果)
- [ ] MinaIllusion (特殊效果)
- [ ] SaraElementShift (?)

## 優先順序

1. **優先級 1 - 基礎攻擊** (遷移最簡單)
   - CommonBasicAttack
   - CommonGuard
   - CommonStandUp
   - CommonRest

2. **優先級 2 - 普通攻擊** (有倍率但無特殊效果)
   - CyrusSwordStrike
   - EliseVineLash
   - RagLavaPunch
   - RagEarthQuake

3. **優先級 3 - 複雜動作** (需要特殊處理)
   - 治療類: EliseNatureHeal, SaraEnergyRepair
   - 防禦類: CyrusLightBarrier, RagRockShield
   - 控制類: MinaHypnosis, MinaIllusion
   - 其他: CyrusRoyalCommand, MinaDreamErosion, SaraAlchemyBomb, SaraElementShift

## 技術備註

- 所有新檔案需要新增 `effects: Array[EffectComponent]` 屬性
- 移除舊屬性但不移除 @deprecated 標記的（保持 Action.gd 兼容）
- 若檔案有 `cast_time`, `applicable_ranges` 等舊欄位，一起移除
- 確保每個檔案的 ExtResource 引用正確

