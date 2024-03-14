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
	symbol_selected_from_image.connect(_save_selected_symbol)
	symbol_selected_from_tree.connect(_save_selected_symbol)
	symbol_deselected.connect(_free_selected_symbol)
	
	symbol_edit_started.connect(_turn_edit_state_on)
	symbol_edited.connect(_update_edited_status)
	symbol_edit_ended.connect(_turn_edit_state_off)
	
	
func _save_selected_symbol(xml_id: int, symbol_id: int):
	selected_xml_id = xml_id
	selected_symbol_id = symbol_id
	is_selected = true
	
	
func _free_selected_symbol():
	selected_xml_id = -1
	selected_symbol_id = -1
	is_selected = false
	
	
func _turn_edit_state_on(xml_id: int, symbol_id: int):
	is_editing = true

	
func _turn_edit_state_off():
	is_editing = false
	
	
func _update_edited_status(xml_id: int, symbol_id: int):
	get_tree().call_group("draw_group", "on_redraw_requested")
	ProjectManager.active_project.xml_status[xml_id].dirty = true

