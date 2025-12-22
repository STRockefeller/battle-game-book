# Character.gd
class_name Character
extends Resource

# Basic info
@export var name_translations: Dictionary = {
	"zh_TW": "未命名",
	"en": "Unnamed"
}

# Visual resources
@export var character_assets: CharacterAssets = null

# Core stats
@export var agility: int = 10

# Max values
@export var max_hp: int = 100
@export var max_mp: int = 50
@export var max_stamina: int = 100

# Actions (passive traits now selected dynamically at battle start)
@export var available_actions: Array[Action] = []

# Managers
var effect_manager: StatusEffectManager
var stance_manager: StanceManager

func _init() -> void:
    effect_manager = StatusEffectManager.new(self)
    stance_manager = StanceManager.new(self)

# ==================== Stance helpers ====================
func change_stance(stance_type: Stance.Type, duration: int = -1) -> void:
    stance_manager.change_stance(stance_type, duration)

func get_current_stance() -> Stance.Type:
    return stance_manager.get_current_stance_type()

func get_current_stance_name() -> String:
    return stance_manager.get_current_stance_name()

func can_perform_action(action_tag: String) -> bool:
    return stance_manager.can_perform_action(action_tag)

func is_stance(stance_type: Stance.Type) -> bool:
    return stance_manager.is_stance(stance_type)

# ==================== Effect helpers ====================
func apply_effect(effect: StatusEffect) -> void:
    effect_manager.apply_effect(effect)

func remove_effect(effect_id: String) -> void:
    effect_manager.remove_effect(effect_id)

func on_turn_start() -> void:
    stance_manager.on_turn_start()
    effect_manager.on_turn_start()

func on_turn_end() -> void:
    stance_manager.on_turn_end()
    effect_manager.on_turn_end()

# ==================== Modifiers ====================
func get_stat_modifier(stat_type: String) -> float:
    # 所有效果修正器現在由 BattleManager 通過 effect_manager 管理
    return effect_manager.get_stat_modifier(stat_type)

func get_damage_bonus_percent() -> float:
    return clamp(get_stat_modifier("damage_bonus") * 100.0, -100.0, 200.0)

func get_defense_reduction_percent() -> float:
    return clamp(get_stat_modifier("defense_bonus") * 100.0, 0.0, 90.0)

func get_accuracy_bonus() -> int:
    return int(get_stat_modifier("accuracy_bonus"))

func get_evasion_bonus() -> int:
    return int(get_stat_modifier("evasion_bonus"))

func get_crit_rate_bonus_percent() -> float:
    return get_stat_modifier("crit_rate_bonus") * 100.0

# ==================== Derived stats ====================
func get_effective_stat(stat_type: String) -> float:
    # 用於排序等邏輯，目前僅需要敏捷值
    if stat_type == "agi" or stat_type == "agility":
        return float(agility)
    return 0.0

# ==================== HP helpers ====================
func take_damage(damage: int) -> void:
    print("%s 受到 %d 傷害" % [get_display_name(), damage])

func heal(amount: int) -> void:
    print("%s 恢復 %d 生命值" % [get_display_name(), amount])

func is_alive(current_hp: int) -> bool:
    return current_hp > 0

# ==================== Localization ====================
func get_display_name() -> String:
    var locale = TranslationServer.get_locale()
    if name_translations.has(locale):
        return name_translations[locale]
    return name_translations.get("zh_TW", "未命名")
