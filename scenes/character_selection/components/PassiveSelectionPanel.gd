extends Control
class_name PassiveSelectionPanel

signal confirmed(selected_ids: Array[String])
signal canceled()

@onready var title_label: Label = $Panel/VBox/Title
@onready var list_container: VBoxContainer = $Panel/VBox/ScrollContainer/List
@onready var status_label: Label = $Panel/VBox/Status
@onready var buttons_row: HBoxContainer = $Panel/VBox/Buttons
@onready var confirm_button: Button = $Panel/VBox/Buttons/Confirm
@onready var cancel_button: Button = $Panel/VBox/Buttons/Cancel

var max_select: int = 2
var _traits: Array = []
var _selected: Array[String] = []
var _checkbox_by_id: Dictionary = {}

func _ready() -> void:
	_status_update()

func setup(max_select_count: int = 2) -> void:
	max_select = max_select_count
	_traits = PassiveTraitLibrary.get_all_traits()
	_build_list()
	title_label.text = "選擇被動特質 (最多 %d 項)" % max_select

func _build_list() -> void:
	# 清空舊項目
	for child in list_container.get_children():
		child.queue_free()
	_checkbox_by_id.clear()
	for pasive_trait in _traits:
		var row := HBoxContainer.new()
		row.custom_minimum_size = Vector2(0, 36)
		var cb := CheckButton.new()
		cb.text = "%s - %s" % [pasive_trait.name, pasive_trait.description]
		cb.connect("toggled", Callable(self, "_on_trait_toggled").bind(pasive_trait.id))
		row.add_child(cb)
		_checkbox_by_id[pasive_trait.id] = cb
		list_container.add_child(row)

func _on_trait_toggled(pressed: bool, trait_id: String) -> void:
	if pressed:
		if _selected.size() >= max_select:
			status_label.text = "最多只能選擇 %d 項" % max_select
			# revert toggle by id
			if _checkbox_by_id.has(trait_id):
				var cb: CheckButton = _checkbox_by_id[trait_id]
				cb.button_pressed = false
			return
		_selected.append(trait_id)
	else:
		_selected.erase(trait_id)
	_status_update()

func _status_update() -> void:
	status_label.text = "已選擇: %d/%d" % [_selected.size(), max_select]
	confirm_button.disabled = _selected.is_empty()

func _on_confirm_pressed() -> void:
	confirmed.emit(_selected.duplicate())

func _on_cancel_pressed() -> void:
	canceled.emit()
