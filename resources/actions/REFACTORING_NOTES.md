# Action System Refactoring - File Organization

## Overview

All 19 Action `.tres` resource files have been reorganized and cleaned up to align with the new modular effect component architecture.

## Changes Made

### 1. File Structure Reorganization

**Before:**
```
resources/actions/
├── CommonBasicAttack.tres
├── CommonGuard.tres
├── EliseVineLash.tres
└── ... (19 files in flat structure)
```

**After:**
```
resources/actions/
├── common_basic_attack/
│   ├── action.tres
│   └── effects/
├── common_guard/
│   ├── action.tres
│   └── effects/
├── elise_vine_lash/
│   ├── action.tres
│   └── effects/
└── ... (19 actions with consistent structure)
```

### 2. Attribute Cleanup

#### Removed Deprecated Attributes:
- `damage` - Damage is now managed by `DamageEffect` component
- `cast_time` - No longer used in current design
- `accuracy_by_range` - Simplified to single `accuracy` value
- `effects_on_hit` - Replaced by EffectComponent system with execution times
- `effects_on_use` - Replaced by EffectComponent system with execution times
- `damage_multiplier` - Consolidated into `DamageEffect`
- `power` - Replaced by damage calculation in effects
- `accuracy_modifier` - Changed to direct `accuracy` property
- `critical_modifier` - Changed to direct `critical_rate` property
- `applicable_ranges` - Managed by action targeting system
- `out_of_range_penalty` - Not applicable with new range system
- `target_stance_change_enabled` / `target_stance_change_to` - Use `StanceEffect` component
- `user_stance_change_enabled` / `user_stance_change_to` - Use `StanceEffect` component

#### New/Updated Attributes:
- `accuracy` - Base hit chance (default: 100.0)
- `critical_rate` - Crit chance (default: 0.0)
- `effects` - Array of EffectComponent instances (default: [])

### 3. File Naming Convention

All action resource files are now consistently named `action.tres` within their action-specific directories:

- `common_basic_attack/action.tres` (not common_basic_attack.tres)
- `elise_vine_lash/action.tres` (not EliseVineLash.tres)
- `cyrus_light_barrier/action.tres` (not CyrusLightBarrier.tres)

This naming provides:
- **Consistency**: All action files have the same name
- **Clarity**: Directory name clearly indicates the action
- **Scalability**: Easy to add effect-related files in the `effects/` subfolder

## New File Structure for Actions

Each action now follows this pattern:

```
resources/actions/{action_id}/
├── action.tres              # Main action resource file
├── effects/                 # Subdirectory for effect components
│   ├── damage_1.tres       # Example: DamageEffect for this action
│   ├── dot_1.tres          # Example: DOTEffect (damage over time)
│   └── stance_1.tres       # Example: StanceEffect
└── README.md               # (Optional) Action documentation
```

## Effect Component Organization

The `effects/` subdirectories are reserved for organizing action-specific effect component files. Currently empty by default, they provide a location for:

- **Custom DamageEffect** configurations per action
- **Conditional effects** (e.g., extra damage at low health)
- **Multiple effect chains** (action causing multiple effects)
- **Action-specific modifiers** via StatModifierEffect

### Example: Complex Action with Multiple Effects

```
resources/actions/elise_vine_lash/
├── action.tres
└── effects/
    ├── physical_damage.tres        # DamageEffect: STR scaling
    ├── poison_dot.tres             # DOTEffect: Applies poison
    ├── accuracy_penalty.tres       # ControlEffect: Reduces accuracy next turn
    └── stance_change.tres          # StanceEffect: Changes to AGGRESSIVE
```

## Property Reference for action.tres

### Preserved Core Properties:
```gdscript
id: String                              # Unique action identifier (snake_case)
name: String                            # Display name in UI
description: String                    # Flavor text / effect description
action_assets: ActionAssets            # Visual assets (sprite, animation, VFX)
animation_duration: float              # How long the animation plays
cost_stamina: int                       # Stamina cost to execute
cost_mp: int                            # Mana/resource cost
cooldown: int                           # Turns before next use
allowed_stances: PackedStringArray      # Stances that can use this action
disallowed_stances: PackedStringArray   # Stances that cannot use this action
tags: PackedStringArray                 # Action categorization (for filtering)
priority: int                           # Turn order if multiple actions selected
```

### New Effect System Properties:
```gdscript
accuracy: float                         # Base hit chance (0-100)
critical_rate: float                    # Crit chance (0-100)
effects: Array[EffectComponent]         # Modular effect instances
```

## Migration Guide for Custom Actions

If creating new actions following this structure:

1. **Create directory**: `resources/actions/my_new_action/`
2. **Create action.tres**: With ID, name, costs, etc.
3. **Create effects/**: Subdirectory for effect components
4. **Add effects**: Link EffectComponent resources in the `effects` array

Example `my_new_action/action.tres`:
```godot
[gd_resource type="Resource" script_class="Action"]
id = "my_new_action"
name = "新招式"
description = "這是一個新的招式"
cost_stamina = 5
cost_mp = 10
accuracy = 90.0
critical_rate = 15.0
effects = [
    SubResource("damage_effect"),
    SubResource("stun_effect")
]
priority = 2
```

## Benefits of This Organization

✅ **Separation of Concerns**: Action metadata separate from effect components  
✅ **Scalability**: Easy to add effects without cluttering the action file  
✅ **Consistency**: Standardized naming and structure for all 19 actions  
✅ **Maintainability**: Clear hierarchy makes it obvious where to find/modify effects  
✅ **Modularity**: Effects can be reused across actions  
✅ **Future-proof**: Ready for action variants, templates, or inheritance patterns

## Related Documentation

- **[Action.md](../docs/Action.md)**: Action system design and formulas
- **[StatusEffectSystem.md](../docs/StatusEffectSystem.md)**: Old effects (now replaced by EffectComponent)
- **[BattleSystemArchitecture.md](../docs/BattleSystemArchitecture.md)**: Overall battle system design
- **Script Reference**: [Action.gd](../../scripts/character/action/Action.gd)
- **Effect Components**: [scripts/character/action/effect_component/](../../scripts/character/action/effect_component/)

## Notes

- All 19 actions have been successfully migrated
- Files maintain UTF-8 encoding with no BOM
- No functional changes to game mechanics; this is purely a structural refactoring
- BattleManager and all action loading code remains backward-compatible
- Next phase: Populate `effects/` subdirectories with specific effect component configurations
