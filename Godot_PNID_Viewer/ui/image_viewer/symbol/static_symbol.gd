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
	var symbol_size = symbol_object.get_size()
	
	# draw set (rect draw)
	var size = symbol_size
	var color = symbol_object.origin_xml.color
	var width = Config.DEFAULT_LINE_WIDTH
	static_symbol_draw.global_position = symbol_center
	static_symbol_draw.rotation = deg_to_rad(symbol_object.get_godot_degree())
	
	static_symbol_draw.update_draw(size,color,width)
	if symbol_object.removed:
		static_symbol_draw.visible = false
	else:
		static_symbol_draw.visible = true
	

func process_input(event):
	if event is InputEventMouseButton and (event.button_index == MOUSE_BUTTON_LEFT or event.button_index == MOUSE_BUTTON_RIGHT):
		if event.is_pressed() and not symbol_object.removed:
			if symbol_object.has_point(get_global_mouse_position()):
				report_static_selected.emit(self)


func set_label_visibility(enabled: bool):
	static_label.visible = enabled

