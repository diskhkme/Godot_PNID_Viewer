# Symbol edit interface
# abstraction of seding/receiving symbol editing to SymbolManager

extends Node
class_name SymbolEditInterface

signal symbol_edit_started_received(xml_id:int, symbol_id:int)
signal symbol_edited_received(xml_id:int, symbol_id:int)
signal symbol_edit_ended_received()


func _ready():
	# received symbol_edited
	SymbolManager.symbol_edit_started.connect(on_symbol_edit_started_received)
	SymbolManager.symbol_edited.connect(on_symbol_edited_received)
	SymbolManager.symbol_edit_ended.connect(on_symbol_edit_ended_received)


func on_symbol_edit_started_received(object: Object, xml_id:int, symbol_id:int):
	if object != self:
		symbol_edit_started_received.emit(xml_id, symbol_id)


func on_symbol_edited_received(object: Object, xml_id:int, symbol_id:int):
	# filter out my send
	if object != self:
		symbol_edited_received.emit(xml_id,symbol_id)

		
func on_symbol_edit_ended_received(object: Object):
	if object != self:
		symbol_edit_ended_received.emit()


# call this if want to send selection
func symbol_edit_started_send(xml_id: int, symbol_id: int):
	SymbolManager.symbol_edit_started.emit(self, xml_id, symbol_id)


func symbol_edited_send(xml_id: int, symbol_id: int):
	SymbolManager.symbol_edited.emit(self, xml_id, symbol_id)
	

func symbol_edit_ended_send():
	SymbolManager.symbol_edit_ended.emit(self)
	
	
func get_is_editing():
	return SymbolManager.is_editing
	
	
