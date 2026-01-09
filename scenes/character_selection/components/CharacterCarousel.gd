extends Control
class_name CharacterCarousel

signal selection_changed(character: Character)

@export var card_scene: PackedScene
@export var animation_duration: float = 0.4

@onready var cards_container: Control = $Cards

var characters: Array[Character] = []
var card_nodes: Array[CharacterCard] = []
var center_index: int = 0
var _is_animating: bool = false
var _node_offset_indices: Array[int] = [] # 每張卡片在佈局 offset 列表中的索引

func _ready() -> void:
	pass

func set_characters(list: Array) -> void:
	characters = list.duplicate()
	center_index = 0
	_rebuild_cards()
	_apply_layout()
	selection_changed.emit(get_current_character())

func move_left() -> void:
	if _block_navigation():
		return
	_rotate_carousel(-1)

func move_right() -> void:
	if _block_navigation():
		return
	_rotate_carousel(1)

func is_animating() -> bool:
	return _is_animating

func get_current_character() -> Character:
	if characters.is_empty():
		return null
	return characters[center_index]

func _block_navigation() -> bool:
	return _is_animating or characters.size() <= 1

# direction: 1=向右旋轉（center_index++），-1=向左旋轉（center_index--）
func _rotate_carousel(direction: int) -> void:
	_is_animating = true

	# 使用佈局索引進行環形包覆
	var layout := _get_layout_definition(card_nodes.size())
	var offsets: Array = layout["offsets"]
	var scales: Array = layout["scales"]
	var alphas: Array = layout["alphas"]
	var rotations: Array = layout["rotations"]
	var z_indices: Array = layout["z_indices"]
	var char_offsets: Array = layout["char_offsets"]

	# 更新中心角色索引（先更新，讓角色指派正確）
	center_index = _wrap_index(center_index + direction)

	for i in range(card_nodes.size()):
		var card := card_nodes[i]
		var current_index := _node_offset_indices[i]
		var target_index := int(((current_index - direction) % char_offsets.size() + char_offsets.size()) % char_offsets.size())
		var target_offset: int = char_offsets[target_index]
		
		# 更新將要顯示的角色
		var new_char_index := _wrap_index(center_index + target_offset)
		card.set_character(characters[new_char_index])
		
		# 動畫到目標狀態
		var is_center := (target_offset == 0)
		var delay: float = abs(target_offset) * 0.02
		card.visible = true
		card.animate_to_state(
			offsets[target_index],
			scales[target_index],
			alphas[target_index],
			rotations[target_index],
			z_indices[target_index],
			is_center,
			delay
		)
		
		# 更新當前索引為目標索引
		_node_offset_indices[i] = target_index
	
	# 等待動畫完成
	await get_tree().create_timer(animation_duration + 0.1).timeout
	_is_animating = false
	selection_changed.emit(get_current_character())

# 已不需要單獨的淡出/移出邏輯；索引旋轉後始終維持固定可視張數

func _rebuild_cards() -> void:
	if card_scene == null:
		push_error("CharacterCarousel: card_scene 未設定")
		return
	for child in cards_container.get_children():
		child.queue_free()
	card_nodes.clear()
	_node_offset_indices.clear()

	var visible_count: int = min(5, characters.size())
	for i in range(visible_count):
		var card: CharacterCard = card_scene.instantiate()
		cards_container.add_child(card)
		card_nodes.append(card)
		_node_offset_indices.append(i) # 初始與佈局索引一致

# 初始化佈局（無動畫）
func _apply_layout() -> void:
	if characters.is_empty():
		return
	if card_nodes.is_empty():
		return

	var layout := _get_layout_definition(card_nodes.size())
	var offsets: Array = layout["offsets"]
	var scales: Array = layout["scales"]
	var alphas: Array = layout["alphas"]
	var rotations: Array = layout["rotations"]
	var z_indices: Array = layout["z_indices"]
	var char_offsets: Array = layout["char_offsets"]

	# 初始化每張卡片至對應的佈局位置
	for i in range(card_nodes.size()):
		var card := card_nodes[i]
		var offset_val: int = char_offsets[i]
		_node_offset_indices[i] = i
		var character_index := _wrap_index(center_index + offset_val)
		card.set_character(characters[character_index])
		card.position = offsets[i]
		card.scale = Vector2(scales[i], scales[i])
		card.modulate = Color(1, 1, 1, alphas[i])
		card.rotation = deg_to_rad(rotations[i])
		card.z_index = z_indices[i]
		var is_center: bool = (offset_val == 0)
		var panel_alpha := 1.0 if is_center else 0.7
		card.get_node("Panel").modulate = Color(1, 1, 1, panel_alpha)
		var font_color := Color(1, 1, 1, 1) if is_center else Color(0.85, 0.85, 0.85, 1)
		card.get_node("Panel/Name").add_theme_color_override("font_color", font_color)

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
				"rotations": [0.0],
				"z_indices": [10],
				"char_offsets": [0]
			}
		2:
			return {
				"offsets": [Vector2(-140, 0), Vector2(140, 0)],
				"scales": [1.0, 0.95],
				"alphas": [1.0, 0.8],
				"rotations": [0.0, 3.0],
				"z_indices": [10, 5],
				"char_offsets": [0, 1]
			}
		3:
			return {
				"offsets": [Vector2(-200, 0), Vector2.ZERO, Vector2(200, 0)],
				"scales": [0.9, 1.05, 0.9],
				"alphas": [0.7, 1.0, 0.7],
				"rotations": [-3.5, 0.0, 3.5],
				"z_indices": [5, 10, 5],
				"char_offsets": [-1, 0, 1]
			}
		4:
			return {
				"offsets": [Vector2(-260, 0), Vector2(-100, 0), Vector2(100, 0), Vector2(260, 0)],
				"scales": [0.85, 1.0, 1.0, 0.85],
				"alphas": [0.65, 1.0, 0.9, 0.65],
				"rotations": [-5.0, -2.0, 2.0, 5.0],
				"z_indices": [3, 8, 8, 3],
				"char_offsets": [-1, 0, 1, 2]
			}
		_:
			return {
				"offsets": [Vector2(-320, 0), Vector2(-160, 0), Vector2.ZERO, Vector2(160, 0), Vector2(320, 0)],
				"scales": [0.8, 0.9, 1.05, 0.9, 0.8],
				"alphas": [0.35, 0.7, 1.0, 0.7, 0.35],
				"rotations": [-6.0, -3.0, 0.0, 3.0, 6.0],
				"z_indices": [1, 5, 10, 5, 1],
				"char_offsets": [-2, -1, 0, 1, 2]
			}
