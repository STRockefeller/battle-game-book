extends Action
class_name Guard

func _init() -> void:
    id = "common_guard"
    action_name = "防守"
    description = "進入防守姿態，減少受到的傷害。"
    
    # 資源消耗
    cost_stamina = 15
    cost_mp = 0
    
    # 冷卻時間
    cooldown_turns = 0
    
    # 傷害參數
    damage_multiplier = 0.0  # 防守不造成傷害
    
    # 狀態效果
    applies_status_effects = []
    
    # 姿態限制
    usable_stances = []  # 所有姿態都可用
    
    # 優先級
    execution_priority = 5
    
    # 動作資源
    action_assets = ActionAssets.new()
    action_assets.animation_sprite = "res://assets/sprites/actions/common/guard.svg"
    action_assets.animation_name = "guard"
    action_assets.hit_vfx_scene = "res://assets/vfx/actions/guard.tscn"
    action_assets.audio_file = "res://assets/audio/actions/guard.ogg"


func can_use(caster: Character, battle_state: BattleState) -> bool:
    """檢查是否可以使用此動作"""
    var caster_state = battle_state.get_character_state(caster.id)
    
    # 檢查體力消耗
    if caster_state.stamina < cost_stamina:
        return false
    
    # 檢查冷卻時間
    if caster_state.cooldowns.has(id) and caster_state.cooldowns[id] > 0:
        return false
    
    return true


func is_usable_in(stance: Stance) -> bool:
    """檢查該姿態是否能使用此動作"""
    # 防守動作在任何姿態都可使用
    if usable_stances.is_empty():
        return true
    
    return usable_stances.has(stance)


func apply_effect(caster: Character, target: Character, battle_state: BattleState, battle_logic: BattleLogic) -> Dictionary:
    """應用防守效果"""
    var result = {
        "caster": caster.id,
        "target": target.id,
        "action_id": id,
        "damage": 0,
        "hit": true,
        "status_applied": []
    }
    
    # 消耗體力
    var target_state = battle_state.get_character_state(target.id)
    target_state.stamina -= cost_stamina
    
    # 應用冷卻時間
    target_state.cooldowns[id] = cooldown_turns
    
    # 應用防守狀態效果（通常會套用防禦Buff）
    if not applies_status_effects.is_empty():
        for status_effect in applies_status_effects:
            target_state.active_status_effects.append(status_effect.id)
            result["status_applied"].append(status_effect.id)
    
    return result