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

func set_slot_state(scale_value: float, alpha_value: float, highlighted: bool) -> void:
	scale = Vector2(scale_value, scale_value)
	modulate = Color(1, 1, 1, alpha_value)
	panel.modulate = Color(1, 1, 1, 0.2) if not highlighted else Color(1, 1, 1, 0.35)
	var font_color := Color(1, 1, 1, 1) if highlighted else Color(0.85, 0.85, 0.85, 1)
	name_label.add_theme_color_override("font_color", font_color)
