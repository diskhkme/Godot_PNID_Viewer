extends MarginContainer
class_name SymbolViewControl

signal report_focused(xml_id:int, symbol_id: int)
signal report_defocused()
signal report_edited(xml_id:int, symbol_id: int)

@export var stylebox = preload("res://resources/symbol_info_rowitem_focused.tres")

@onready var left = $HBoxContainer/Left
@onready var right = $HBoxContainer/Right
@onready var type_label = $HBoxContainer/Left/TypeLabel
@onready var cls_label = $HBoxContainer/Left/ClsLabel
@onready var text_label = $HBoxContainer/Left/ClsTextLabel

@onready var symbol_selection_interface = $SymbolSelectionInterface
@onready var symbol_edit_interface = $SymbolEditInterface

var type_items_id = {}
var cls_items_id = {}

var xml_id
var symbol_id
var symbol_object

func _ready():
	symbol_selection_interface.symbol_selected_received.connect(focus_selected_symbol)
	symbol_edit_interface.symbol_edited_received.connect(update_edited_symbol)


func set_type_items(symbol_type_set: Array):
	var id = 0
	for type_item in symbol_type_set:
		type_label.add_item(type_item)
		type_items_id[type_item] = id
		id += 1
		
		
func set_cls_items(symbol_cls_set: Array):
	var id = 0
	for cls_item in symbol_cls_set:
		cls_label.add_item(cls_item)
		cls_items_id[cls_item] = id
		id += 1
		

func initialize(xml_id: int, symbol_object: SymbolObject, 
					symbol_type_set: Array,
					symbol_cls_set: Array):
	self.focus_mode = Control.FOCUS_ALL
	self.xml_id = xml_id
	self.symbol_id = symbol_object.id
	self.symbol_object = symbol_object
	set_type_items(symbol_type_set)
	set_cls_items(symbol_cls_set)
	
	fill_symbol_info()
	

func fill_symbol_info():
	left.get_child(0).text = str(symbol_object.id)
	type_label.select(type_items_id[symbol_object.type])
	if symbol_object.type.to_lower().contains(Config.TEXT_TYPE_NAME):
		cls_label.visible = false
		text_label.visible = true
		text_label.text = symbol_object.cls
	else:
		cls_label.visible = true
		text_label.visible = false
		cls_label.select(cls_items_id[symbol_object.cls])

	right.get_child(0).text = str(int(symbol_object.bndbox.x))
	right.get_child(1).text = str(int(symbol_object.bndbox.y))
	right.get_child(2).text = str(int(symbol_object.bndbox.z))
	right.get_child(3).text = str(int(symbol_object.bndbox.w))
	right.get_child(4).text = str(int(symbol_object.degree))


func _draw():
	if has_focus():
		draw_style_box(stylebox, Rect2(Vector2(0,0), size))


# --- Select(send)
func _on_focus_entered():
	symbol_selection_interface.symbol_selected_send(xml_id, symbol_id)
	
	
func _on_focus_exited():
	symbol_selection_interface.symbol_deselected_send()
	
	
# --- Select(received)
func focus_selected_symbol(xml_id: int, symbol_id: int):
	if self.xml_id == xml_id and self.symbol_id == symbol_id:
		grab_focus()
	

# --- Edit(send)
func _on_type_label_item_selected(index):
	if index == type_items_id[Config.TEXT_TYPE_NAME]:
		cls_label.visible = false
		text_label.visible = true
		symbol_object.cls = text_label.text
	else:
		cls_label.visible = true
		text_label.visible = false
		symbol_object.cls = cls_items_id.find_key(cls_label.get_selected_id())
	
	symbol_edit_interface.symbol_edited_send(xml_id, symbol_id)


func _on_cls_label_item_selected(index):
	# only happens when not text
	symbol_object.cls = cls_items_id.find_key(index)
	symbol_edit_interface.symbol_edited_send(xml_id, symbol_id)


func _on_cls_text_label_text_changed(new_text):
	# only happens when text
	symbol_object.cls = new_text
	symbol_edit_interface.symbol_edited_send(xml_id, symbol_id)
	
	
# --- Edit(received)
func update_edited_symbol(xml_id: int, symbol_id: int):
	if self.xml_id == xml_id and self.symbol_id == symbol_id:
		fill_symbol_info()



