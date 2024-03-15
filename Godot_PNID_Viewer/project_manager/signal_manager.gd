# Signal manager (autoload)
# Global signal passthrough from symbol select/edit + xml visilibility change

extends Node # TODO: scene instead of autoload?

signal symbol_selected_from_image(symbol_object: SymbolObject)
signal symbol_selected_from_tree(symbol_object: SymbolObject)
signal symbol_deselected()

signal symbol_edit_started(symbol_object: SymbolObject)
signal symbol_edited(symbol_object: SymbolObject)
signal symbol_added(symbol_object: SymbolObject)
signal symbol_edit_ended()

signal xml_visibility_changed(xml_data: XMLData)
signal xml_selectability_changed(xml_data: XMLData)
signal xml_added(xml_data: XMLData)

var is_editing: bool = false
var selected_symbol: SymbolObject
var is_selected: bool = false

func _ready():
	symbol_selected_from_image.connect(_save_selected_symbol)
	symbol_selected_from_tree.connect(_save_selected_symbol)
	symbol_deselected.connect(_free_selected_symbol)
	
	symbol_edit_started.connect(_turn_edit_state_on)
	symbol_edited.connect(_on_symbol_edited)
	symbol_edit_ended.connect(_turn_edit_state_off)
	
	
func _save_selected_symbol(symbol_object: SymbolObject):
	selected_symbol = symbol_object
	is_selected = true
	
	
func _free_selected_symbol():
	selected_symbol = null
	is_selected = false
	
	
func _turn_edit_state_on(symbol_object: SymbolObject):
	is_editing = true

	
func _turn_edit_state_off():
	is_editing = false
	
	
func _on_symbol_edited(symbol_object: SymbolObject):
	get_tree().call_group("draw_group", "on_redraw_requested")
	symbol_object.source_xml.dirty = true

