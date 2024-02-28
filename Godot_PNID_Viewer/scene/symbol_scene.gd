# symbol scene
# display symbols with "draw" if not selected, 
# and add manipulation handle when selected

extends Node2D

@export var static_symbol_display: PackedScene
@export var editing_symbol_display: PackedScene

@onready var symbol_selection_filter: SymbolSelectionFilter = $SymbolSelectionFilter

var selected_candidate: Array[StaticSymbolDisplay]


func populate_symbol_bboxes(xml_status: Array) -> void:
	for xml_stat in xml_status:
		for symbol_object in xml_stat.symbol_objects:	
			var symbol = static_symbol_display.instantiate() as StaticSymbolDisplay
			symbol.xml_id = xml_stat.id
			symbol.symbol_object = symbol_object
			self.add_child(symbol)
			symbol.report_selected.connect(on_symbol_select_reported)


func _input(event):
	if ProjectManager.active_project == null:
		return
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if !event.is_pressed():
			var selected: StaticSymbolDisplay = symbol_selection_filter.decided_selected(selected_candidate)
			if selected == null:
				SymbolManager.symbol_deselected.emit()
			else:
				SymbolManager.symbol_selected.emit(selected.xml_id, selected.symbol_object.id)
			
			selected_candidate.clear()


func on_symbol_select_reported(symbol: StaticSymbolDisplay):
	selected_candidate.push_back(symbol)
		
