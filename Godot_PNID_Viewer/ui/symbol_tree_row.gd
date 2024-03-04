extends MarginContainer
class_name SymbolInfoRow

@export var stylebox: StyleBox

@onready var left = $HBoxContainer/Left
@onready var right = $HBoxContainer/Right

@onready var type_label = $HBoxContainer/Left/TypeLabel
@onready var cls_label = $HBoxContainer/Left/ClsLabel
@onready var text_label = $HBoxContainer/Left/ClsTextLabel

var type_items_id = {}
var cls_items_id = {}


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
		

func set_data(symbol_object: SymbolObject) -> void:
	left.get_child(0).text = str(symbol_object.id)
	type_label.select(type_items_id[symbol_object.type])
	if symbol_object.type.to_lower().contains("text"):
		cls_label.visible = false
		text_label.visible = true
		text_label.text = symbol_object.cls
	else:
		cls_label.visible = true
		text_label.visible = false
		cls_label.select(cls_items_id[symbol_object.cls])

	right.get_child(0).text = str(symbol_object.bndbox.x)
	right.get_child(1).text = str(symbol_object.bndbox.y)
	right.get_child(2).text = str(symbol_object.bndbox.z)
	right.get_child(3).text = str(symbol_object.bndbox.w)
	right.get_child(4).text = str(symbol_object.degree)


func _draw():
	if has_focus():
		draw_style_box(stylebox, Rect2(Vector2(0,0), size))


func _on_type_label_item_selected(index):
	# called when type changed
	pass
