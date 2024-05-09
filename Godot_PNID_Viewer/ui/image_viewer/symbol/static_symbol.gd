# Static symbol display
# draw symbols not in editing state

extends Node2D
class_name StaticSymbol

# signal to symbol scene for filtering selection
signal report_static_selected(obj: StaticSymbol)

@onready var static_symbol_draw = $StaticSymbolDraw
@onready var static_label = $StaticSymbolDraw/StaticLabel

var symbol_object: SymbolObject
var on_cursor: bool = false

func _ready():
	update_symbol()
	static_label.update_label(symbol_object)

	
func update_symbol():
	var symbol_center = symbol_object.get_center()
	
	
	# draw set (rect draw)
	static_symbol_draw.global_position = symbol_center
	static_symbol_draw.rotation = deg_to_rad(symbol_object.get_godot_degree())
	static_symbol_draw.symbol_object = symbol_object
	
	if symbol_object.removed:
		static_symbol_draw.visible = false
	else:
		static_symbol_draw.visible = true
	

func process_input(event):
	if event is InputEventMouseButton and (event.button_index == MOUSE_BUTTON_LEFT or event.button_index == MOUSE_BUTTON_RIGHT):
		if event.is_pressed() and _check_selectability():
			if symbol_object.has_point(get_global_mouse_position()):
				report_static_selected.emit(self)


func _check_selectability() -> bool:
	if symbol_object.removed:
		return false
	if symbol_object.is_text and not symbol_object.source_xml.is_text_visible:
		return false
	if not symbol_object.is_text and not symbol_object.source_xml.is_symbol_visible:
		return false
		
	return true


func set_label_visibility(enabled: bool):
	static_label.visible = enabled

