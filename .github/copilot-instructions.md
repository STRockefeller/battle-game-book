# Battle Game Book - AI Coding Assistant Instructions

## Project Overview

This is a **Godot 4.x turn-based battle game** written in **GDScript** (繁體中文 documentation). The architecture emphasizes **separation of concerns** with pure logic, serializable state, and visual layers to support both single-player and multiplayer modes.

## Core Architecture Principles

### Three-Layer Battle System

1. **BattleLogic** (`scripts/BattleLogic.gd`) - Pure, stateless calculation functions
   - All methods are deterministic (same input → same output)
   - Used for server validation and client prediction
   - Examples: `calculate_hit()`, `calculate_damage_result()`, `validate_action()`

2. **BattleState** (`scripts/BattleState.gd`) - Serializable state container
   - Manages HP/MP/STA, cooldowns, and stance for both players
   - Methods: `to_dict()`, `from_dict()`, `calculate_hash()` for network sync
   - No game logic - just state storage and serialization

3. **BattleManager** (`scripts/BattleManager.gd`) - Orchestration and signals
   - Base class for single-player mode (direct AI integration)
   - Extended by `ServerBattleManager` and `ClientBattleManager` for multiplayer
   - Emits signals: `turn_start_selection`, `action_executed`, `battle_ended`

### Resource-Based Data Model

All game data uses **Godot Resources** (`.tres` files) with `class_name` declarations:

- **Character** (`scripts/character/Character.gd`): Stats calculated from base attributes (STR, INT, AGI, CON, LUK). Formula: `ATK = STR × 2`, `HP = CON × 20`, etc.
- **Action** (`scripts/character/action/Action.gd`): Skills/moves with cost (STA/MP), cooldown, stance restrictions, and visual assets
- **StatusEffect** (`scripts/character/status_effect/StatusEffect.gd`): Buffs/debuffs with `stat_modifiers` (passive) and `effect_parameters` (active triggers)

**Naming Convention**: 
- Characters: `resources/characters/[Name].tres` (e.g., `Elise.tres`)
- Actions: `resources/actions/[Character][Action].tres` or `Common[Action].tres` (e.g., `EliseVineLash.tres`, `CommonGuard.tres`)

### Stance vs Status Effects

- **Stance** (`scripts/character/stance/`): **Exclusive** state (enum-based, not resource). Only one active. Filters available actions (e.g., `KNOCKED_DOWN` → only "起身" action). Managed by `StanceManager` per character.
- **StatusEffect**: **Stackable** buffs/debuffs (resource-based). Multiple can coexist. Modify stats or trigger events (e.g., poison deals damage per turn).

### Asset Management System

- **AssetManager** (`scripts/AssetManager.gd`): Singleton for loading sprites/audio/VFX with **fallback mechanism**
  - Always tries specific path first, falls back to `DEFAULT_PATHS` on failure
  - Example: Missing `hero/attack.png` → uses `default_character.svg`
  
- **CharacterVisualState** + **BattleVisualPlayer** (`scripts/CharacterVisualState.gd`, `scripts/BattleVisualPlayer.gd`): Handle animation state and playback coordination

- **Asset Structure**: 
  ```
  assets/sprites/[character]/[state].svg  (idle, attack, hit, etc.)
  assets/audio/[character|action]/[sound].ogg
  assets/vfx/[type]/[effect].tscn
  ```

## Key Systems

### AI System (`scripts/ai/`)

- Base class: `AIBehavior` with `choose_action()` method
- Implementations: `AggressiveAI`, `DefensiveAI`, `BalancedAI`
- AI assigned to characters in `BattleManager._ready()`
- **Note**: AI is code-based (not resources) for flexibility

### Battle Flow (Single-Player)

1. `BattleManager.start_battle()` → emits `turn_start_selection`
2. UI calls `player_select_action()`, AI uses `_ai_select_action()`
3. When both selected → `_resolve_turn()` calculates order via `BattleLogic.calculate_execution_order()`
4. Actions applied → emits `action_executed` per action
5. Turn ends → cooldowns tick down, effects process → emits `turn_ended`

## Development Conventions

### Language

- **Code**: GDScript (Godot 4.x syntax with typed variables)
- **Comments/Docs**: 繁體中文 (Traditional Chinese)
- **Variable names**: English (snake_case for variables, PascalCase for classes)

### Git Commit Convention

- **Commit Message Format**: Follow the Gitmoji format defined in `.vscode/snippets/git-commit.json`
  - Examples: `✨ feat: Add new feature`, `🐛 fix: Fix bug`, `📝 docs: Update documentation`, `♻️ refactor: Refactor code`
  - Always use appropriate emoji prefix for commit type
- **⚠️ Git Operations**: **NEVER commit changes without explicit user confirmation**
  - Always ask user for approval before running `git add` or `git commit`
  - Show what will be committed and wait for confirmation

### File Organization

- Scripts under `scripts/` with subdirectories: `ai/`, `character/action/`, `character/status_effect/`, `character/stance/`
- Resources under `resources/` with subdirectories: `actions/`, `characters/`, `statuses/`
- Documentation in `assets/docs/` (detailed .md files explaining systems)

### Critical Patterns

1. **Always use `class_name`** for custom types to enable global access
2. **Extend `Resource`** for data classes (Character, Action, StatusEffect)
3. **Use signals** for UI/logic decoupling (see BattleManager signals)
4. **Calculate derived stats** in `Character.calculate_base_stats()` - never store them in .tres
5. **Fallback assets**: AssetManager handles missing resources gracefully - no hard crashes

## Testing & Running

- **Run in Godot Editor** (F5), not from command line
- Main scene: `scenes/MainMenu.tscn` → CharacterSelection → Battle
- **VS Code errors are false positives** - GDScript language server lags. Verify in Godot Output panel.
- Test guides: `QUICK_TEST_GUIDE.md`, `TEST_CHECKLIST.md`

## Common Gotchas

1. **Character stats must be calculated**: Call `character.calculate_base_stats()` after modifying base attributes
2. **Action availability**: Check both `can_use()` (resources) and `is_usable_in()` (stance) before showing actions
3. **Cooldown format**: Stored as `{action.id: remaining_turns}` in BattleState
4. **Effect triggers**: `StatusEffectManager.on_turn_start()` and `on_turn_end()` must be called by BattleManager
5. **Asset paths**: Always use `res://` protocol, not absolute paths

## Example: Adding a New Action

1. Create `resources/actions/HeroFireball.tres` (right-click → New Resource → Action)
2. Set properties: `id="hero_fireball"`, `name="火球術"`, `cost_mp=20`, `damage_multiplier=1.5`
3. Add to Character: Open `resources/characters/Hero.tres`, add to `available_actions` array
4. Create visuals: `assets/sprites/actions/fireball.svg` and `assets/vfx/actions/fireball.tscn`
5. Link in Action: Set `action_assets` → `animation_sprite`, `hit_vfx_scene` properties

## Documentation References

- **Architecture**: `assets/docs/BattleSystemArchitecture.md` (370 lines - full system design)
- **Character Stats**: `assets/docs/Character.md` (formulas and examples)
- **Actions**: `assets/docs/Action.md` (parameters and mechanics)
- **Status Effects**: `assets/docs/StatusEffectSystem.md` (implementation guide)
- **Stances**: `assets/docs/Stance.md` (vs status effects distinction)
- **Assets**: `assets/docs/AssetManagementSystem.md` (500+ lines implementation detail)

---

**Critical**: This project uses **Godot 4.x** (not 3.x). Check `project.godot` config_version=5. Always test in Godot Editor, not external tools.
