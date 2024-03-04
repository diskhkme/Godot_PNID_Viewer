# Symbol edit interface
# abstraction of seding/receiving symbol editing to SymbolManager

extends Node
class_name SymbolEditInterface

signal symbol_edited_received(object: Object, xml_id:int, symbol_id:int)


func _ready():
	# received symbol_edited
	SymbolManager.symbol_edited.connect(on_symbol_edited_received)


func on_symbol_edited_received(object: Object, xml_id:int, symbol_id:int):
	# filter out my send
	if object != self:
		symbol_edited_received.emit(xml_id,symbol_id)


# call this if want to send selection
func symbol_edited_send(xml_id: int, symbol_id: int):
	SymbolManager.symbol_edited.emit(self, xml_id, symbol_id)
	
	
