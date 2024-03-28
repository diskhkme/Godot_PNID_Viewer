# symbol scene
# display symbols with "draw" if not selected

extends Node2D
class_name XMLScene

const StaticSymbol: PackedScene = preload("res://ui/image_viewer/symbol/static_symbol.tscn")

var _selected_candidate: Array[StaticSymbol]
var _selection_filter
var _symbol_nodes = {}
var _xml_data 

func populate_symbol_bboxes(xml_data: XMLData) -> void:
	_xml_data = xml_data
	Util.log_start("populate_xml %s" % xml_data.filename)
	for symbol_object in xml_data.symbol_objects:
		_add_child_static_symbol(symbol_object)
	Util.log_end("populate_xml %s" % xml_data.filename)


func process_input(event):
	_symbol_nodes.values().map(func(s): s.process_input(event))


func set_watched_filter(selection_filter: SymbolSelectionFilter):
	_selection_filter = selection_filter
	
	
func has_symbol(symbol_object: SymbolObject):
	return _symbol_nodes.has(symbol_object)
	
	
func get_candidate():
	return _selected_candidate
	
	
func get_xml_data():
	return _xml_data
	

# THE slow part
func _add_child_static_symbol(symbol_object: SymbolObject):
	var symbol = StaticSymbol.instantiate() as StaticSymbol
	symbol.name = str(symbol_object.id)
	symbol.symbol_object = symbol_object 
	symbol.report_static_selected.connect(on_static_symbol_select_reported)
	self.add_child(symbol)
	_symbol_nodes[symbol_object] = symbol


func update_visibility():
	_symbol_nodes.keys().map(func(s): 
		if s.is_text:
			if _xml_data.is_text_visible:
				_symbol_nodes[s].visible = true
			else:
				_symbol_nodes[s].visible = false
		else:
			if _xml_data.is_symbol_visible:
				_symbol_nodes[s].visible = true
			else:
				_symbol_nodes[s].visible = false)

	
func clear_candidates():
	_selected_candidate.clear()
	

func on_static_symbol_select_reported(symbol: StaticSymbol) -> void:
	if not _selected_candidate.has(symbol):
		_selected_candidate.push_back(symbol)
	
	
func apply_symbol_edit(symbol_object: SymbolObject):
	_symbol_nodes[symbol_object].update_symbol()
	
	
func show_symbol_node(symbol_object: SymbolObject):
	_symbol_nodes[symbol_object].visible = true
	

func hide_symbol_node(symbol_object: SymbolObject):
	_symbol_nodes[symbol_object].visible = false
	
	
func add_symbol_node(symbol_object: SymbolObject):
	_add_child_static_symbol(symbol_object)
	
	
func remove_symbol_node(symbol_object: SymbolObject): # undo add
		_symbol_nodes[symbol_object].free() # delete node
		_symbol_nodes.erase(symbol_object) # delete in dict


func set_label_visibility(enabled: bool):
	for static_symbol in _symbol_nodes.values():
		static_symbol.set_label_visibility(enabled)
