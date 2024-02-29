# Symbol manager
# control and emit symbol selection and editing
# actual signal is colled from symbol scene and symbol tree

extends Node

signal symbol_selected_from_image(xml_id: int, symbol_id: int)
signal symbol_selected_from_tree(xml_id: int, symbol_id: int)
signal symbol_deselected

signal symbol_edit_started
signal symbol_edit_ended

var selected_xml_id: int
var selected_symbol_id: int
var is_editing: bool = false

func _ready():
	symbol_selected_from_image.connect(on_symbol_selected)
	symbol_selected_from_tree.connect(on_symbol_selected)
	symbol_deselected.connect(on_symbol_deselected)
	symbol_edit_started.connect(on_symbol_edit_start)
	symbol_edit_ended.connect(on_symbol_edit_end)
	
	
func on_symbol_selected(xml_id: int, symbol_id: int):
	selected_xml_id = xml_id
	selected_symbol_id = symbol_id
	symbol_edit_started.emit()
	
func on_symbol_deselected():
	selected_xml_id = -1
	selected_symbol_id = -1

	
func on_symbol_edit_start():
	is_editing = true
	
	
func on_symbol_edit_end():
	symbol_deselected.emit()
	is_editing = false
