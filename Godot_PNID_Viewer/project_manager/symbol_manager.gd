# Symbol manager
# Global signal passthrough from symbol select/edit interface
# Maintain is_editing state

extends Node # TODO: scene instead of autoload?

signal symbol_selected_from_image(xml_id: int, symbol_id: int)
signal symbol_selected_from_tree(xml_id: int, symbol_id: int)
signal symbol_deselected()

signal symbol_edit_started(xml_id: int, symbol_id: int)
signal symbol_edited(xml_id: int, symbol_id: int)
signal symbol_added(xml_id: int, symbol_id: int)
signal symbol_edit_ended()

var is_editing: bool = false
var selected_xml_id
var selected_symbol_id
var is_selected: bool = false

func _ready():
	symbol_selected_from_image.connect(on_symbol_selected)
	symbol_selected_from_tree.connect(on_symbol_selected)
	symbol_deselected.connect(on_symbol_deselected)
	
	symbol_edit_started.connect(on_symbol_edit_started)
	symbol_edited.connect(on_symbol_edited)
	symbol_edit_ended.connect(on_symbol_edit_end)
	
	
func on_symbol_selected(xml_id: int, symbol_id: int):
	selected_xml_id = xml_id
	selected_symbol_id = symbol_id
	is_selected = true
	
	
func on_symbol_deselected():
	selected_xml_id = -1
	selected_symbol_id = -1
	is_selected = false
	
	
func on_symbol_edit_started(xml_id: int, symbol_id: int):
	is_editing = true

	
func on_symbol_edit_end():
	is_editing = false
	
	
func on_symbol_edited(xml_id: int, symbol_id: int):
	get_tree().call_group("draw_group", "on_redraw_requested")
	ProjectManager.active_project.xml_status[xml_id].dirty = true

