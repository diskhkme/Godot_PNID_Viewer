extends Node

signal symbol_selected_from_image(xml_id: int, symbol_id: int)
signal symbol_selected_from_tree(xml_id: int, symbol_id: int)
signal symbol_deselected

signal symbol_edit_started
signal symbol_edit_ended

var is_editing: bool = false

func _ready():
	symbol_edit_started.connect(on_symbol_edit_start)
	symbol_edit_ended.connect(on_symbol_edit_end)
	
	
func on_symbol_edit_start():
	is_editing = true
	
	
func on_symbol_edit_end():
	is_editing = false
