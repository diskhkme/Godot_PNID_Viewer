# Symbol editor 
# activates editor controller when selected, deactivates when edit ended

extends Node2D
class_name SymbolEditor

@onready var symbol_editor_controller = $SymbolEditorController

func _ready():
	SymbolManager.symbol_edit_started.connect(show_editor)
	SymbolManager.symbol_edit_ended.connect(hide_editor)
	SymbolManager.symbol_deselected.connect(hide_editor)
	visible = false


func show_editor(xml_id:int, symbol_id:int):
	visible = true


func hide_editor():
	visible = false
	
	
# TODO: continuously report symbol change to symbol manager, by receiveing the information from editor controller
	
