# Symbol editor 
# activates editor controller when selected, deactivates when edit ended

extends Node2D
class_name SymbolEditor

@onready var symbol_editor_controller = $SymbolEditorController
@onready var symbol_selection_interface = $SymbolSelectionInterface # remove?
@onready var symbol_edit_interface = $SymbolEditInterface


func _ready():
	symbol_edit_interface.symbol_edit_started_received.connect(show_editor)
	symbol_edit_interface.symbol_edit_ended_received.connect(hide_editor)
	visible = false


func show_editor(xml_id:int, symbol_id:int):
	visible = true


func hide_editor():
	visible = false
	
	
# TODO: continuously report symbol change to symbol manager, by receiveing the information from editor controller
	
