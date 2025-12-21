extends Control
class_name CharacterCarousel

signal selection_changed(character: Character)

@export var card_scene: PackedScene
@export var animation_duration: float = 0.3
@export var slide_distance: float = 160.0

@onready var cards_container: Control = $Cards

var characters: Array[Character] = []
var card_nodes: Array[CharacterCard] = []
var center_index: int = 0
var _base_position: Vector2
var _is_animating: bool = false

func _ready() -> void:
	_base_position = cards_container.position

func set_characters(list: Array) -> void:
	characters = list.duplicate()
	center_index = 0
	_rebuild_cards()
	_apply_layout()
	selection_changed.emit(get_current_character())

func move_left() -> void:
	if _block_navigation():
		return
	center_index = _wrap_index(center_index - 1)
	_start_slide(-1)

func move_right() -> void:
	if _block_navigation():
		return
	center_index = _wrap_index(center_index + 1)
	_start_slide(1)

func is_animating() -> bool:
	return _is_animating

func get_current_character() -> Character:
	if characters.is_empty():
		return null
	return characters[center_index]

func _block_navigation() -> bool:
	return _is_animating or characters.size() <= 1

func _start_slide(direction: int) -> void:
	_is_animating = true
	cards_container.position = _base_position + Vector2(direction * slide_distance, 0.0)
	_apply_layout()
	var tween := create_tween()
	tween.tween_property(cards_container, "position", _base_position, animation_duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.finished.connect(_on_slide_finished)

func _on_slide_finished() -> void:
	_is_animating = false
	selection_changed.emit(get_current_character())

func _rebuild_cards() -> void:
	if card_scene == null:
		push_error("CharacterCarousel: card_scene 未設定")
		return
	for child in cards_container.get_children():
		child.queue_free()
	card_nodes.clear()

	var visible_count: int = min(5, characters.size())
	for i in range(visible_count):
		var card: CharacterCard = card_scene.instantiate()
		cards_container.add_child(card)
		card_nodes.append(card)

func _apply_layout() -> void:
	if characters.is_empty():
		return
	if card_nodes.is_empty():
		return

	var layout := _get_layout_definition(card_nodes.size())
	var offsets: Array = layout["offsets"]
	var scales: Array = layout["scales"]
	var alphas: Array = layout["alphas"]
	var char_offsets: Array = layout["char_offsets"]
	for i in range(card_nodes.size()):
		var card := card_nodes[i]
		var character_index := _wrap_index(center_index + char_offsets[i])
		card.set_character(characters[character_index])
		card.position = offsets[i]
		card.set_slot_state(scales[i], alphas[i], char_offsets[i] == 0)

func _wrap_index(value: int) -> int:
	if characters.is_empty():
		return 0
	var size := characters.size()
	return int(((value % size) + size) % size)

func _get_layout_definition(count: int) -> Dictionary:
	match count:
		1:
			return {
				"offsets": [Vector2.ZERO],
				"scales": [1.05],
				"alphas": [1.0],
				"char_offsets": [0]
			}
		2:
			return {
				"offsets": [Vector2(-140, 0), Vector2(140, 0)],
				"scales": [1.0, 0.95],
				"alphas": [1.0, 0.8],
				"char_offsets": [0, 1]
			}
		3:
			return {
				"offsets": [Vector2(-200, 0), Vector2.ZERO, Vector2(200, 0)],
				"scales": [0.9, 1.05, 0.9],
				"alphas": [0.7, 1.0, 0.7],
				"char_offsets": [-1, 0, 1]
			}
		4:
			return {
				"offsets": [Vector2(-260, 0), Vector2(-100, 0), Vector2(100, 0), Vector2(260, 0)],
				"scales": [0.85, 1.0, 1.0, 0.85],
				"alphas": [0.65, 1.0, 0.9, 0.65],
				"char_offsets": [-1, 0, 1, 2]
			}
		_:
			return {
				"offsets": [Vector2(-320, 0), Vector2(-160, 0), Vector2.ZERO, Vector2(160, 0), Vector2(320, 0)],
				"scales": [0.8, 0.9, 1.05, 0.9, 0.8],
				"alphas": [0.35, 0.7, 1.0, 0.7, 0.35],
				"char_offsets": [-2, -1, 0, 1, 2]
			}
