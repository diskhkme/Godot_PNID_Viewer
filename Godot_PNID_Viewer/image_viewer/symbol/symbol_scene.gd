# symbol scene
# display symbols with "draw" if not selected

extends Node2D
class_name SymbolScene

@export var static_symbol: PackedScene = preload("res://image_viewer/symbol/static_symbol.tscn")

var selected_candidate: Array[StaticSymbol]
var selection_filter
var xml_stat

func _ready():
	SymbolManager.symbol_added.connect(add_new_symbol)


func populate_symbol_bboxes(xml_stat: XML_Status) -> void:
	self.xml_stat = xml_stat
	for symbol_object in xml_stat.symbol_objects:	
		add_child_static_symbol(xml_stat.id, symbol_object)


func add_child_static_symbol(xml_id:int, symbol_object: SymbolObject):
	var symbol = static_symbol.instantiate() as StaticSymbol
	symbol.xml_id = xml_id
	symbol.symbol_object = symbol_object
	symbol.report_static_selected.connect(on_static_symbol_select_reported)
	self.add_child(symbol)


func set_watched_filter(selection_filter: SymbolSelectionFilter):
	self.selection_filter = selection_filter
	

func add_new_symbol(xml_id:int, symbol_id:int):
	var symbol_object = ProjectManager.get_symbol_in_xml(xml_id, symbol_id)
	add_child_static_symbol(xml_id, symbol_object)


func clear_candidates():
	selected_candidate.clear()
	

func on_static_symbol_select_reported(symbol: StaticSymbol) -> void:
	if !selected_candidate.has(symbol):
		selected_candidate.push_back(symbol)
	
	
