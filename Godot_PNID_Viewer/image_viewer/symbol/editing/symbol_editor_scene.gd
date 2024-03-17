# Symbol editor 
# activates editor controller when selected, deactivates when edit ended

extends Node2D
class_name SymbolEditor

@onready var symbol_editor_controller = $SymbolEditorController

func _ready():
	SignalManager.symbol_selected.connect(_show_editor)
	#SignalManager.symbol_edit_ended.connect(_hide_editor)
	SignalManager.symbol_deselected.connect(_hide_editor)
	visible = false


func _show_editor(symbol_object: SymbolObject):
	visible = true


func _hide_editor(symbol_object: SymbolObject):
	visible = false
	
