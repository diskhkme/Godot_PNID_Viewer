# symbol scene
# display symbols with "draw" if not selected

extends Node2D

@export var static_symbol: PackedScene

@onready var symbol_selection_filter: SymbolSelectionFilter = $SymbolSelectionFilter

var selected_candidate: Array[StaticSymbol]

func populate_symbol_bboxes(xml_status: Array) -> void:
	for xml_stat in xml_status:
		for symbol_object in xml_stat.symbol_objects:	
			var symbol = static_symbol.instantiate() as StaticSymbol
			symbol.xml_id = xml_stat.id
			symbol.symbol_object = symbol_object
			self.add_child(symbol)
			symbol.report_static_selected.connect(on_static_symbol_select_reported)


func _input(event):
	if ProjectManager.active_project == null:
		return
	
	if SymbolManager.is_editing: # ignore selection while editing
		selected_candidate.clear()
		return
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if !event.is_pressed():
			# TODO: becuase of is_editing ignore, history based filtering does not work currently
			var selected = symbol_selection_filter.decided_selected(selected_candidate)
			if selected == null:
				SymbolManager.symbol_deselected.emit()
			else:
				SymbolManager.symbol_selected_from_image.emit(selected.xml_id, selected.symbol_object.id)
		
			selected_candidate.clear()


func on_static_symbol_select_reported(symbol: StaticSymbol) -> void:
	selected_candidate.push_back(symbol)
	
	