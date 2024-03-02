# Symbol editor 
# controls overall symbol editing and reporting to symbol manager
# activates editor controller when selected, deactivates when edit ended

extends Node2D
class_name SymbolEditor

@onready var symbol_editor_controller = $SymbolEditorController


func _ready():
	SymbolManager.symbol_edit_ended.connect(on_symbol_edit_end)
	SymbolManager.symbol_selected_from_image.connect(on_symbol_selected)
	SymbolManager.symbol_selected_from_tree.connect(on_symbol_selected)
	visible = false


func on_symbol_selected(xml_id:int, symbol_id:int):
	visible = true


func on_symbol_edit_end():
	visible = false
	
	
# TODO: continuously report symbol change to symbol manager, by receiveing the information from editor controller
	
