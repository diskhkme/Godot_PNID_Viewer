# symbol scene
# display symbols with "draw" if not selected

extends Node2D
class_name XMLScene

const StaticSymbol: PackedScene = preload("res://ui/image_viewer/symbol/static_symbol.tscn")

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
	var symbol = StaticSymbol.instantiate() as StaticSymbol
	symbol.symbol_object = symbol_object # TODO: or encapsulate create symbol with add_child to avoid internal variable access
	symbol.report_static_selected.connect(on_static_symbol_select_reported)
	self.add_child(symbol)
	symbol_nodes[symbol_object] = symbol


func update_visibility():
	symbol_nodes.keys().map(func(s): 
		if s.is_text:
			if xml_data.is_text_visible:
				symbol_nodes[s].visible = true
			else:
				symbol_nodes[s].visible = false
		else:
			if xml_data.is_symbol_visible:
				symbol_nodes[s].visible = true
			else:
				symbol_nodes[s].visible = false)

	
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
		symbol_nodes[symbol_object].free() # delete node
		symbol_nodes.erase(symbol_object) # delete in dict


func set_label_visibility(enabled: bool):
	for static_symbol in symbol_nodes.values():
		static_symbol.set_label_visibility(enabled)
