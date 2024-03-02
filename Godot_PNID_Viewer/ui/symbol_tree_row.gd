extends MarginContainer
class_name SymbolInfoRow

@export var stylebox: StyleBox

@onready var left = $HBoxContainer/Left
@onready var right = $HBoxContainer/Right

func set_data(symbol_object: SymbolObject) -> void:
	left.get_child(0).text = str(symbol_object.id)
	left.get_child(1).text = symbol_object.type
	left.get_child(2).text = symbol_object.cls
	right.get_child(0).text = str(symbol_object.bndbox.x)
	right.get_child(1).text = str(symbol_object.bndbox.y)
	right.get_child(2).text = str(symbol_object.bndbox.z)
	right.get_child(3).text = str(symbol_object.bndbox.w)
	right.get_child(4).text = str(symbol_object.degree)


func _draw():
	if has_focus():
		draw_style_box(stylebox, Rect2(Vector2(0,0), size))
