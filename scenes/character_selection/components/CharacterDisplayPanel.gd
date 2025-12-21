extends Control
class_name CharacterDisplayPanel

@onready var portrait_rect: TextureRect = $Panel/VBox/Portrait
@onready var name_label: Label = $Panel/VBox/Name
@onready var title_label: Label = $Panel/VBox/Title

const DEFAULT_SPRITE: String = "res://assets/sprites/characters/no_face/selection.png"
const DEFAULT_NAME: String = "???"

func _ready() -> void:
	clear()

func set_title(text: String) -> void:
	title_label.text = text

func set_character(character: Character) -> void:
	var sprite_path := DEFAULT_SPRITE
	var display_name := DEFAULT_NAME

	if character != null:
		display_name = character.name
		if character.character_assets:
			sprite_path = character.character_assets.sprite_selection

	var texture := AssetManager.get_instance().load_character_sprite(sprite_path)
	portrait_rect.texture = texture
	name_label.text = display_name

func clear() -> void:
	var texture := AssetManager.get_instance().load_character_sprite(DEFAULT_SPRITE)
	portrait_rect.texture = texture
	name_label.text = DEFAULT_NAME
