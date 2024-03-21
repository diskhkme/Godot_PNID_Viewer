# symbol scene
# display symbols with "draw" if not selected

extends Node2D
class_name XMLScene

const static_symbol: PackedScene = preload("res://ui/image_viewer/symbol/static_symbol.tscn")

var selected_candidate: Array[StaticSymbol]
var selection_filter
var symbol_nodes = {}
var xml_data

func populate_symbol_bboxes(xml_data: XMLData) -> void:
	self.xml_data = xml_data
	for symbol_object in xml_data.symbol_objects:	
		_add_child_static_symbol(symbol_object)


func set_watched_filter(selection_filter: SymbolSelectionFilter):
	self.selection_filter = selection_filter
	

func _add_child_static_symbol(symbol_object: SymbolObject):
	var symbol = static_symbol.instantiate() as StaticSymbol
	symbol.symbol_object = symbol_object # TODO: or encapsulate create symbol with add_child to avoid internal variable access
	symbol.report_static_selected.connect(on_static_symbol_select_reported)
	self.add_child(symbol)
	symbol_nodes[symbol_object] = symbol
	
	
func clear_candidates():
	selected_candidate.clear()
	

func on_static_symbol_select_reported(symbol: StaticSymbol) -> void:
	if not selected_candidate.has(symbol):
		selected_candidate.push_back(symbol)
	
	
func apply_symbol_edit(symbol_object: SymbolObject):
	symbol_nodes[symbol_object].update_symbol()
	
	
func show_symbol_node(symbol_object: SymbolObject):
	symbol_nodes[symbol_object].visible = true
	

func hide_symbol_node(symbol_object: SymbolObject):
	symbol_nodes[symbol_object].visible = false
	
	
func add_symbol_node(symbol_object: SymbolObject):
	_add_child_static_symbol(symbol_object)
	
	
func remove_symbol_node(symbol_object: SymbolObject):
	symbol_nodes[symbol_object].free()
