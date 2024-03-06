extends Window

@onready var type_option_button = $VBoxContainer/MarginContainer/VBoxContainer/HBoxContainer/TypeOptionButton
@onready var cls_option_button = $VBoxContainer/MarginContainer/VBoxContainer/HBoxContainer2/ClassOptionButton
@onready var cls_text_edit = $VBoxContainer/MarginContainer/VBoxContainer/HBoxContainer2/TextEdit

var xml_stat: XML_Status
var symbol_object: SymbolObject

func show_type_change_window(xml_stat: XML_Status, symbol_object: SymbolObject):
	self.xml_stat = xml_stat
	self.symbol_object = symbol_object
	type_option_button.clear()
	for type in ProjectManager.symbol_type_set:
		type_option_button.add_item(type)
		
	cls_option_button.clear()
	for cls in ProjectManager.symbol_type_set[symbol_object.type]:
		cls_option_button.add_item(cls)
		
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


func _on_type_option_button_item_selected(index):
	if ProjectManager.is_symbol_type_text(index):
		cls_option_button.visible = false
		cls_text_edit.visible = true
	else:
		cls_option_button.visible = true
		cls_text_edit.visible = false
	
	
func update_symbol_object():
	symbol_object.type = type_option_button.get_item_text(type_option_button.selected)
	if symbol_object.is_text:
		symbol_object.cls = cls_text_edit.text
	else:
		symbol_object.cls = cls_option_button.get_item_text(cls_option_button.selected)
	
		
# change only applied when pressed OK
func _on_ok_button_pressed():
	update_symbol_object()
	SymbolManager.symbol_edited.emit(xml_stat.id, symbol_object.id)
	self.visible = false


func _on_cancel_button_pressed():
	self.visible = false


func _on_close_requested():
	self.visible = false



