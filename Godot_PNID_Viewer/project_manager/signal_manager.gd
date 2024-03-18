# Signal manager (autoload)
# Global signal passthrough from symbol select/edit + xml visilibility change

extends Node # TODO: scene instead of autoload?

signal report_progress(percent: float)

signal symbol_selected(symbol_object: SymbolObject) # selected == edit start
signal symbol_deselected(symbol_object: SymbolObject) # deselected == edit end

signal symbol_edited(symbol_object: SymbolObject)
signal symbol_added(symbol_object: SymbolObject)

signal xml_visibility_changed(xml_data: XMLData)
signal xml_selectability_changed(xml_data: XMLData)
signal xml_label_visibility_changed(xml_data: XMLData)
signal xml_added(xml_data: XMLData)

var selected_symbol: SymbolObject
var is_selected: bool = false # == is editing

func _ready():
	symbol_selected.connect(_save_selected_symbol)
	symbol_deselected.connect(_free_selected_symbol)
	symbol_edited.connect(_on_symbol_edited)
	
	
func _save_selected_symbol(symbol_object: SymbolObject):
	#print(symbol_object.id, " selected")
	selected_symbol = symbol_object
	is_selected = true
	
	
func _free_selected_symbol(symbol_object: SymbolObject):
	#print(symbol_object.id, " deselected")
	selected_symbol = null
	is_selected = false
	
	
func _on_symbol_edited(symbol_object: SymbolObject):
	get_tree().call_group("draw_group", "on_redraw_requested")
	

