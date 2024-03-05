# symbol scene
# display symbols with "draw" if not selected

extends Node2D
class_name SymbolScene

@export var static_symbol: PackedScene = preload("res://scene/symbol_scene/static_symbol.tscn")

#@onready var symbol_selection_filter: SymbolSelectionFilter = $SymbolSelectionFilter
#@onready var symbol_selection_interface = $SymbolSelectionInterface
#@onready var symbol_edit_interface = $SymbolEditInterface

var selected_candidate: Array[StaticSymbol]
var selection_filter
var xml_stat

func _ready():
	selection_filter.clear_selected_candidate.connect(clear_candidates)


func populate_symbol_bboxes(xml_stat: XML_Status) -> void:
	self.xml_stat = xml_stat
	for symbol_object in xml_stat.symbol_objects:	
		var symbol = static_symbol.instantiate() as StaticSymbol
		symbol.xml_id = xml_stat.id
		symbol.symbol_object = symbol_object
		symbol.report_static_selected.connect(on_static_symbol_select_reported)
		self.add_child(symbol)


func set_watched_filter(selection_filter: SymbolSelectionFilter):
	self.selection_filter = selection_filter
	

#func _input(event):
	#if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		#if !event.is_pressed():
			#selected_candidate.clear()
	
	#if ProjectManager.active_project == null:
		#return
	#
	#if symbol_edit_interface.get_is_editing() == true:
		#selected_candidate.clear()
		#return
	#
	#if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		#if !event.is_pressed():
			## TODO: becuase of is_editing ignore, history based filtering does not work currently
			#var selected = symbol_selection_filter.decided_selected(selected_candidate)
			#if selected == null:
				#symbol_selection_interface.symbol_deselected_send()
			#else:
				#symbol_selection_interface.symbol_selected_send(selected.xml_id, selected.symbol_object.id)
				#symbol_edit_interface.symbol_edit_started_send(selected.xml_id, selected.symbol_object.id)
		#
			#selected_candidate.clear()

func clear_candidates():
	selected_candidate.clear()
	

func on_static_symbol_select_reported(symbol: StaticSymbol) -> void:
	selected_candidate.push_back(symbol)
	
	
