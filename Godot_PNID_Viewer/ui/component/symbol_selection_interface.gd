# Symbol selection interface
# abstraction of seding/receiving symbol selection to SymbolManager

extends Node
class_name SymbolSelectionInterface

signal symbol_selected_received(object: Object, xml_id:int, symbol_id:int)


func _ready():
	# received symbol_selected
	SymbolManager.symbol_selected.connect(on_symbol_selected_received)


func on_symbol_selected_received(object: Object, xml_id:int, symbol_id:int):
	# filter out my send
	if object != self:
		symbol_selected_received.emit(object,xml_id,symbol_id)


# call this if want to send selection
func symbol_selected_send(xml_id: int, symbol_id: int):
	SymbolManager.symbol_selected.emit(self, xml_id, symbol_id)
	
	
