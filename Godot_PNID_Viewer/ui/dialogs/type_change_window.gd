extends Window

signal type_change_window_closed

@onready var type_option_button = $VBoxContainer/MarginContainer/VBoxContainer/HBoxContainer/TypeOptionButton
@onready var cls_option_button = $VBoxContainer/MarginContainer/VBoxContainer/HBoxContainer2/ClassOptionButton
@onready var cls_text_edit = $VBoxContainer/MarginContainer/VBoxContainer/HBoxContainer2/TextEdit

var symbol_object: SymbolObject


func show_type_change_window(symbol_object: SymbolObject):
	type_option_button.clear()
	for type in ProjectManager.symbol_type_set:
		type_option_button.add_item(type)
		
	reset_class_with_type(symbol_object.type)
	
	self.symbol_object = symbol_object
		
	type_option_button.select(ProjectManager.symbol_type_set.keys().find(symbol_object.type))
	if symbol_object.is_text:
		cls_option_button.visible = false
		cls_text_edit.visible = true
		cls_text_edit.text = symbol_object.cls
	else:
		cls_option_button.visible = true
		cls_text_edit.visible = false
		cls_option_button.select(ProjectManager.symbol_type_set[symbol_object.type].find(symbol_object.cls))
		
	self.visible = true


func reset_class_with_type(type: String):
	cls_option_button.clear()
	for cls in ProjectManager.symbol_type_set[type]:
		cls_option_button.add_item(cls)


func _on_type_option_button_item_selected(index):
	if ProjectManager.is_symbol_type_text(index):
		cls_option_button.visible = false
		cls_text_edit.visible = true
	else:
		var current_type = ProjectManager.symbol_type_set.keys()[index]
		reset_class_with_type(current_type)
		cls_option_button.visible = true
		cls_text_edit.visible = false
	
	
func check_symbol_updated() -> bool:
	var updated_type = type_option_button.get_item_text(type_option_button.selected)
	var updated_cls
	if cls_text_edit.visible:
		updated_cls = cls_text_edit.text
	else:
		updated_cls = cls_option_button.get_item_text(cls_option_button.selected)
	if symbol_object.is_type_class_same(updated_type, updated_cls):
		return false
		
	return true
	
	
func update_symbol_object():
	symbol_object.type = type_option_button.get_item_text(type_option_button.selected)
	if cls_text_edit.visible:
		symbol_object.cls = cls_text_edit.text
	else:
		symbol_object.cls = cls_option_button.get_item_text(cls_option_button.selected)


# change only applied when pressed OK
# TODO: after closing, XML treeviewer still waits click so selected is jumped(?)
func _on_ok_button_pressed():
	if check_symbol_updated():
		update_symbol_object()
		SignalManager.symbol_edited.emit(symbol_object)
				
	self.visible = false


func _on_cancel_button_pressed():
	self.visible = false


func _on_close_requested():
	self.visible = false




