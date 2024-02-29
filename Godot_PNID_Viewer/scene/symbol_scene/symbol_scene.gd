# symbol scene
# display symbols with "draw" if not selected, 
# display symbol_editor if selected

extends Node2D

@export var static_symbol_display: PackedScene

@onready var symbol_editor: SymbolEditor = $SymbolEditor
@onready var symbol_selection_filter: SymbolSelectionFilter = $SymbolSelectionFilter

var selected_candidate: Array[StaticSymbolDisplay]
var symbol_editor_instance: SymbolEditor


func _ready():
	symbol_editor.visible = false
	SymbolManager.symbol_selected_from_tree.connect(on_symbol_selected)
	SymbolManager.symbol_deselected.connect(on_symbol_deselected)
	

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
			var selected = symbol_selection_filter.decided_selected(selected_candidate)
			if selected == null:
				if SymbolManager.is_editing:
					SymbolManager.symbol_edit_ended.emit()
				else:
					SymbolManager.symbol_deselected.emit()
			else:
				SymbolManager.symbol_selected_from_image.emit(selected.xml_id, selected.symbol_object.id)
			
			selected_candidate.clear()


func on_symbol_select_reported(symbol: StaticSymbolDisplay) -> void:
	selected_candidate.push_back(symbol)
	
	
func on_symbol_selected(xml_id: int, symbol_id: int): 
	symbol_editor.visible = true
	queue_redraw()
	
	
func on_symbol_deselected(): 
	symbol_editor.visible = false
	queue_redraw()
		
