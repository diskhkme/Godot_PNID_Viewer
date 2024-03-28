extends Window

signal symbol_type_changed(_symbol_object: SymbolObject)

@onready var _type_option_button = $VBoxContainer/MarginContainer/VBoxContainer/HBoxContainer/TypeOptionButton
@onready var _cls_option_button = $VBoxContainer/MarginContainer/VBoxContainer/HBoxContainer2/ClassOptionButton
@onready var _cls_text_edit = $VBoxContainer/MarginContainer/VBoxContainer/HBoxContainer2/TextEdit

var _symbol_object: SymbolObject
var _init_type
var _init_cls

func initialize_types(symbol_object: SymbolObject):
	_symbol_object = symbol_object
	_init_type = _symbol_object.type
	_init_cls = _symbol_object.cls
	
	_type_option_button.clear()
	for type in ProjectManager.symbol_type_set:
		_type_option_button.add_item(type)
		
	reset_class_with_type(_symbol_object.type)
		
	_type_option_button.select(ProjectManager.symbol_type_set.keys().find(_symbol_object.type))
	if _symbol_object.is_text:
		_cls_option_button.visible = false
		_cls_text_edit.visible = true
		_cls_text_edit.text = _symbol_object.cls
	else:
		_cls_option_button.visible = true
		_cls_text_edit.visible = false
		_cls_option_button.select(ProjectManager.symbol_type_set[_symbol_object.type].find(_symbol_object.cls))


func reset_class_with_type(type: String):
	_cls_option_button.clear()
	for cls in ProjectManager.symbol_type_set[type]:
		_cls_option_button.add_item(cls)


func _on_type_option_button_item_selected(index):
	if ProjectManager.is_symbol_type_text(index):
		_cls_option_button.visible = false
		_cls_text_edit.visible = true
	else:
		var current_type = ProjectManager.symbol_type_set.keys()[index]
		reset_class_with_type(current_type)
		_cls_option_button.visible = true
		_cls_text_edit.visible = false
	
	
func check_symbol_updated() -> bool:
	var updated_type = _type_option_button.get_item_text(_type_option_button.selected)
	var updated_cls
	if _cls_text_edit.visible:
		updated_cls = _cls_text_edit.text
	else:
		updated_cls = _cls_option_button.get_item_text(_cls_option_button.selected)
	if _symbol_object.is_type_class_same(updated_type, updated_cls):
		return false
		
	return true
	
	
func update_symbol_object():
	_symbol_object.set_type(_type_option_button.get_item_text(_type_option_button.selected))
	if _cls_text_edit.visible:
		_symbol_object.set_cls(_cls_text_edit.text)
	else:
		_symbol_object.set_cls(_cls_option_button.get_item_text(_cls_option_button.selected))


func _on_ok_button_pressed():
	var type = _type_option_button.get_item_text(_type_option_button.selected)
	var cls
	if _cls_text_edit.visible:
		cls = _cls_text_edit.text
	else:
		cls = _cls_option_button.get_item_text(_cls_option_button.selected)
	
	if type != _init_type or cls != _init_cls:
		_symbol_object.type = type
		_symbol_object.cls = cls
		symbol_type_changed.emit(_symbol_object)
		
	self.visible = false


func _on_cancel_button_pressed():
	self.visible = false


func _on_close_requested():
	self.visible = false




