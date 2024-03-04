# Symbol manager
# control and emit symbol selection and editing
# actual signal is colled from symbol scene and symbol tree

extends Node # TODO: scene instead of autoload?

signal symbol_selected_from_image(xml_id: int, symbol_id: int)
signal symbol_selected_from_tree(xml_id: int, symbol_id: int)
signal symbol_selected(object: Object, xml_id: int, symbol_id: int)
signal symbol_deselected

signal symbol_edited(xml_id: int, symbol_id: int)
signal symbol_edit_ended

var selected_obj: Object
var selected_xml_id: int # remove?
var selected_symbol_id: int # remove?
var is_editing: bool = false

func _ready():
	symbol_selected_from_image.connect(on_symbol_selected)
	symbol_selected_from_tree.connect(on_symbol_selected)
	symbol_selected.connect(on_symbol_selected)
	symbol_deselected.connect(on_symbol_deselected)
	
	symbol_edit_ended.connect(on_symbol_edit_end)
	symbol_edited.connect(on_symbol_edited)
	
	
func on_symbol_selected(object: Object, xml_id: int, symbol_id: int):
	selected_obj = object
	selected_xml_id = xml_id
	selected_symbol_id = symbol_id
	is_editing = true

	
func on_symbol_deselected():
	selected_xml_id = -1
	selected_symbol_id = -1


func on_symbol_edit_end():
	symbol_deselected.emit()
	is_editing = false
	
	
func on_symbol_edited(xml_id: int, symbol_id: int):
	ProjectManager.active_project.xml_status[xml_id].dirty = true

