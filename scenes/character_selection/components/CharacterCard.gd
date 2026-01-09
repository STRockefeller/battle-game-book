extends Control
class_name CharacterCard

@onready var portrait_rect: TextureRect = $Panel/Portrait
@onready var name_label: Label = $Panel/Name
@onready var panel: Panel = $Panel

const DEFAULT_SPRITE: String = "res://assets/sprites/characters/no_face/card.png"

var character: Character = null

func set_character(value: Character) -> void:
	character = value
	var sprite_path := DEFAULT_SPRITE
	var display_name := ""

	if value != null:
		display_name = value.get_display_name()
		if value.character_assets:
			sprite_path = value.character_assets.sprite_card

	portrait_rect.texture = AssetManager.get_instance().load_character_sprite(sprite_path)
	name_label.text = display_name

func animate_to_state(target_pos: Vector2, scale_value: float, alpha_value: float, 
						rotation_deg: float, z_index_value: int, highlighted: bool, delay: float = 0.0) -> void:
	# 停止之前的動畫
	var existing_tween := get_tree().get_processed_tweens()
	for t in existing_tween:
		if t.is_valid() and t.get_meta("card_owner", null) == self:
			t.kill()
	
	# 創建新的 Tween
	var tween := create_tween()
	tween.set_parallel(true)
	tween.set_meta("card_owner", self)
	
	# 位置動畫
	tween.tween_property(self, "position", target_pos, 0.35) \
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT).set_delay(delay)
	
	# 縮放動畫
	var target_scale := Vector2(scale_value, scale_value)
	tween.tween_property(self, "scale", target_scale, 0.35) \
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT).set_delay(delay)
	
	# 透明度動畫
	tween.tween_property(self, "modulate", Color(1, 1, 1, alpha_value), 0.3) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT).set_delay(delay)
	
	# 旋轉動畫（轉換度數為弧度）
	var target_rotation := deg_to_rad(rotation_deg)
	tween.tween_property(self, "rotation", target_rotation, 0.4) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT).set_delay(delay)
	
	# Panel 高亮效果
	var panel_alpha := 1.0 if highlighted else 0.7
	var panel_color := Color(1, 1, 1, panel_alpha)
	tween.tween_property(panel, "modulate", panel_color, 0.25) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT).set_delay(delay)
	
	# 文字顏色
	var font_color := Color(1, 1, 1, 1) if highlighted else Color(0.85, 0.85, 0.85, 1)
	tween.tween_callback(func(): name_label.add_theme_color_override("font_color", font_color)).set_delay(delay)
	
	# 設置深度
	z_index = z_index_value
