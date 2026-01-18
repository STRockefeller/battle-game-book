# Story System Implementation

## Overview
The story mode system provides a flexible, data-driven framework for creating narrative-driven game experiences with branching paths, world state management, and consequence-based gameplay.

## Core Components

### 1. Data Structures (scripts/story/)
- **StoryData.gd**: Main story configuration resource
- **StoryEvent.gd**: Individual story events and triggers
- **EventChoice.gd**: Player choices with consequences
- **CalamityStage.gd**: World state stages based on energy levels
- **StoryProgress.gd**: Runtime progress tracking
- **DivineFavorData.gd**: Divine favor system data
- **StoryManager.gd**: Central manager (autoload singleton)

### 2. Key Features

#### World Energy System
- Track world energy (0-100%)
- Energy affects world state visually and mechanically
- Energy changes trigger calamity stages
- Energy thresholds determine endings

#### Event System
- Trigger-based events (energy, battle count, manual, stage-based)
- Event types: narrative, choice, battle, divine_favor
- Choices have consequences (energy, abilities, world state)
- Events can unlock other events

#### Calamity Stages
- 5 stages: Stable (80-100%), Initial (60-79%), Accelerating (40-59%), Crisis (20-39%), Collapse (1-19%)
- Each stage has visual/mechanical effects
- Disabled locations and NPCs
- Character debuffs
- Triggered events

#### Divine Favor System
- Special conditions during battles
- Various types: sacrifice, restriction, choice, race, challenge, memory
- Character-specific or universal
- Risk/reward mechanics

#### Truth Fragment System
- Collectible lore pieces
- 15 total fragments unlock secret ending
- Multi-playthrough progression

### 3. Resource Structure

```
resources/
└── stories/
    ├── [CharacterName]StoryData.tres    # Main story resource
    ├── stages/
    │   ├── [CharacterName]StageStable.tres
    │   ├── [CharacterName]StageInitial.tres
    │   ├── [CharacterName]StageAccelerating.tres
    │   ├── [CharacterName]StageCrisis.tres
    │   └── [CharacterName]StageCollapse.tres
    ├── events/
    │   └── [EventID].tres
    ├── favors/
    │   └── [FavorID].tres
    └── choices/
        └── [ChoiceID].tres
```

### 4. Integration Points

#### With Battle System
```gdscript
# After battle victory
StoryManager.on_battle_victory(energy_gained)

# After battle defeat
StoryManager.on_battle_defeat(energy_lost)
```

#### Starting a Story
```gdscript
# New story
StoryManager.start_story("elise")

# Continue existing
StoryManager.continue_story(saved_progress)
```

#### Triggering Events
```gdscript
# Manual trigger
StoryManager.trigger_event_by_id("event_id")

# Auto-triggered based on conditions
StoryManager.check_event_triggers()
```

#### Handling Choices
```gdscript
# Complete event with choice
StoryManager.complete_event("event_id", chosen_choice)
```

### 5. Creating New Stories

1. **Create StoryData resource**:
   - Set character_id, energy_type
   - Define thresholds and endings
   - Add calamity stages
   - Add events and divine favors

2. **Create CalamityStage resources**:
   - Define energy ranges
   - Set visual/mechanical effects
   - List disabled content
   - Add narrative text

3. **Create StoryEvent resources**:
   - Set trigger conditions
   - Define event type
   - Add choices if applicable
   - Configure rewards/penalties

4. **Create EventChoice resources**:
   - Define choice text
   - Set consequences
   - Add result narrative
   - Configure unlocks

5. **Register in StoryManager**:
   - Add to story_data_cache in load_all_stories()

### 6. Signals

StoryManager emits these signals:
- `story_started(story_data)`: Story begins
- `story_event_triggered(event)`: Event activates
- `world_energy_changed(new_energy, change)`: Energy updates
- `calamity_stage_changed(stage)`: Stage transitions
- `story_ended(ending_type)`: Story concludes
- `truth_fragment_unlocked(fragment_id, total)`: Fragment collected

### 7. Example: Elise Story

See `resources/stories/EliseStoryData.tres` for reference implementation showing:
- Life energy type
- Forest calamity progression
- Multiple endings based on final energy
- Integration with existing EliseStory.gd data

## Design Philosophy

1. **Data-Driven**: All story content defined in resources, easy to edit without code changes
2. **Flexible**: System supports various event types and trigger conditions
3. **Consequence-Based**: Every choice has mechanical and narrative impact
4. **Replayable**: Roguelike elements with meta-progression
5. **Integrated**: Works seamlessly with existing battle and character systems

## TODO

- Implement meta-progression system (memory library, permanent unlocks)
- Create divine favor resource templates
- Build story UI scenes
- Add visual effects for calamity stages
- Implement reinforcement character system
- Add more story events and choices for each character
- Create truth fragment collection UI
