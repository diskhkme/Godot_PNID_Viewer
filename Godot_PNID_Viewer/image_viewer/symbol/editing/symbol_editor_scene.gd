# Symbol editor 
# activates editor controller when selected, deactivates when edit ended

extends Node2D
class_name SymbolEditor

@onready var symbol_editor_controller = $SymbolEditorController

func _ready():
	SymbolManager.symbol_edit_started.connect(_show_editor)
	SymbolManager.symbol_edit_ended.connect(_hide_editor)
	SymbolManager.symbol_deselected.connect(_hide_editor)
	visible = false


func _show_editor(symbol_object: SymbolObject):
	visible = true


func _hide_editor():
	visible = false
	
