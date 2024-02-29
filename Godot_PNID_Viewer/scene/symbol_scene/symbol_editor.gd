# Symbol editor 
# controls symbol editing

extends Node2D
class_name SymbolEditor

@onready var symbol_editor_controller = $SymbolEditorController


func _ready():
	SymbolManager.symbol_selected_from_image.connect(on_symbol_selected)


func on_symbol_selected(xml_id:int, symbol_id:int):
	var target_symbol_object = ProjectManager.active_project.xml_status[xml_id].symbol_objects[symbol_id]
	var symbol_position = target_symbol_object.get_center()
	var symbol_size = target_symbol_object.get_size()
	var symbol_angle = deg_to_rad(target_symbol_object.degree)
	symbol_editor_controller.set_target_symbol(symbol_position, symbol_size, symbol_angle)
