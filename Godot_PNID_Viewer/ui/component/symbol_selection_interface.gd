# Symbol selection interface
# abstraction of seding/receiving symbol selection to SymbolManager

extends Node
class_name SymbolSelectionInterface

signal symbol_selected_received(xml_id:int, symbol_id:int)
signal symbol_deselected_received()

func _ready():
	# received symbol_selected
	SymbolManager.symbol_selected.connect(on_symbol_selected_received)
	SymbolManager.symbol_deselected.connect(on_symbol_deselected_received)


func on_symbol_selected_received(object: Object, xml_id:int, symbol_id:int):
	# filter out self send
	if object != self:
		symbol_selected_received.emit(xml_id,symbol_id)
		

func on_symbol_deselected_received(object: Object):
	# filter out self send
	if object != self:
		symbol_deselected_received.emit()


# call this if want to send selection
func symbol_selected_send(xml_id: int, symbol_id: int):
	SymbolManager.symbol_selected.emit(self, xml_id, symbol_id)
	
	
func symbol_deselected_send():
	SymbolManager.symbol_deselected.emit(self)
