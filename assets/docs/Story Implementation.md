

## Plan: Data-Driven Story Mode

A resource-first framework that adds Story managers and state containers, subscribes to existing battle signals, and applies effects via the current `EffectManager`. This keeps story logic stateless/deterministic in battle, with serialization for meta progression and world energy/disaster. Authoring stays simple: edit `.tres` resources and light-weight configs, not code.

### Steps
1. Define Story resources and state
   - Add scripts/story/StoryState.gd with `to_dict()`, `from_dict()`, `calculate_hash()`.
   - Create resource classes: scripts/story/WorldResource.gd, scripts/story/DivineTask.gd, scripts/story/Deity.gd, scripts/story/StoryEvent.gd, scripts/story/MetaProgress.gd.
   - Author data under resources/story/Worlds/, resources/story/Deities/, resources/story/Tasks/, resources/story/Events/, resources/story/Meta/.
   - Reference themes from Story.md and divine tasks from DivineFavor.md.

2. Add Story managers (autoloads) and signal wiring
   - Implement scripts/story/StoryManager.gd to orchestrate Story Mode; subscribe to `turn_start_selection`, `action_executed`, `turn_ended`, `battle_ended` from scripts/BattleManager.gd.
   - Implement scripts/story/WorldEnergyManager.gd for energy %, thresholds, disaster stages; emit `energy_changed`, `stage_changed`.
   - Implement scripts/story/DivineFavorManager.gd to pick tasks, track progress, apply rewards/penalties via `EffectManager.apply_effects()` paths used in BattleManagerEffectsIntegration.gd.
   - Implement scripts/story/ReinforcementManager.gd to monitor defeat/energy triggers and adjust BattleConfig.gd pre-battle.
   - Implement scripts/story/EventRouter.gd to trigger branching resources/story/Events/ at pre/mid/post battle.

3. Hook pre-/mid-/post-battle integration points
   - Pre-battle: extend CharacterSelection.gd to offer deity/task pick; shuttle via extended BattleConfig.gd fields (e.g., `deity_id`, `task_id`, snapshot of world energy).
   - Mid-turn: use `turn_start_selection` and `action_executed` from scripts/BattleManager.gd to enforce constraints (e.g., “no magic”) and tick task progress; apply temporary `EffectModifier`s for rewards via the existing effect pipeline.
   - Post-battle: on `battle_ended`, update world energies, advance disaster stages, trigger scripts/story/EventRouter.gd; persist Story state.

4. Apply disaster-stage gameplay effects cleanly
   - Map stage effects in resources/story/Worlds/ to standardized effect property keys (damage bonus, stamina cap, action seal tags).
   - Inject these via the same `EffectManager` paths already used in BattleManagerEffectsIntegration.gd, keeping `BattleLogic.gd` stateless and deterministic.
   - For action sealing, integrate with action availability checks in UI wiring in Battle.gd and stance filtering, without editing core calculators in BattleLogic.gd.

5. Story UI overlays and i18n
   - Add lightweight overlays to BattleUI.tscn showing Divine Favor task, progress, and completion banners; world energy deltas per battle.
   - Add a Story hub/map scene (e.g., scenes/story/StoryHub.tscn) to visualize disaster stages and trigger events.
   - Localize all text via Localization.gd, adding keys to zh_TW.po and en.po.

6. Save/meta progression
   - Implement scripts/story/StorySaveManager.gd modeled after SettingsManager.gd, versioned schema under `user://story_save.json`.
   - Persist `StoryState` (selected character, world energies, completed tasks, truth fragments) with `to_dict()`/`from_dict()`; auto-save on `battle_ended` and event resolution.

### Further Considerations
1. Autoload scope: Story managers as autoloads vs scene-local controllers? Recommend autoloads for cross-scene continuity.
2. Data model detail: Rewards as `EffectModifier`s vs direct state mutations? Prefer modifiers for determinism and reuse.
3. Authoring workflow: Start with one world and 3–5 tasks to validate UX before scaling.
