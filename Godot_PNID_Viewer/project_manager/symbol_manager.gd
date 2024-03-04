# Symbol manager
# Global signal passthrough from symbol select/edit interface
# Maintain is_editing state

extends Node # TODO: scene instead of autoload?

signal symbol_selected(object: Object, xml_id: int, symbol_id: int)
signal symbol_deselected(object: Object)

signal symbol_edit_started(object: Object, xml_id: int, symbol_id: int)
signal symbol_edited(object: Object, xml_id: int, symbol_id: int)
signal symbol_edit_ended(object: Object)

var is_editing: bool = false

func _ready():
	symbol_edit_started.connect(on_symbol_edit_started)
	symbol_edited.connect(on_symbol_edited)
	symbol_edit_ended.connect(on_symbol_edit_end)
	
	
func on_symbol_edit_started(object: Object, xml_id: int, symbol_id: int):
	is_editing = true

	
func on_symbol_edit_end(object: Object):
	is_editing = false
	
	
func on_symbol_edited(object: Object, xml_id: int, symbol_id: int):
	get_tree().call_group("draw_group", "on_redraw_requested")
	ProjectManager.active_project.xml_status[xml_id].dirty = true

