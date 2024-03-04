# Symbol editor 
# controls overall symbol editing and reporting to symbol manager
# activates editor controller when selected, deactivates when edit ended

extends Node2D
class_name SymbolEditor

@onready var symbol_editor_controller = $SymbolEditorController
@onready var symbol_selection_interface = $SymbolSelectionInterface
@onready var symbol_edit_interface = $SymbolEditInterface


func _ready():
	symbol_selection_interface.symbol_selected_received.connect(show_editor)
	symbol_selection_interface.symbol_deselected_received.connect(hide_editor)
	visible = false


func show_editor(xml_id:int, symbol_id:int):
	visible = true


func hide_editor():
	visible = false
	
	
# TODO: continuously report symbol change to symbol manager, by receiveing the information from editor controller
	
