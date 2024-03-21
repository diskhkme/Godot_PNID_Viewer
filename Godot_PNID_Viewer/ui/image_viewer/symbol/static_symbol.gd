# Static symbol display
# draw symbols not in editing state

extends Node2D
class_name StaticSymbol

# signal to symbol scene for filtering selection
signal report_static_selected(obj: StaticSymbol)

@onready var area = $Area2D
@onready var collision = $Area2D/CollisionShape2D
@onready var static_symbol_draw = $StaticSymbolDraw
@onready var static_label = $StaticSymbolDraw/StaticLabel

var symbol_object: SymbolObject
var on_cursor: bool = false

func _ready():
	add_to_group("draw_group")
	update_symbol()
	static_label.update_label(symbol_object)
	
	
func redraw():
	update_symbol()
	static_symbol_draw.queue_redraw()
	
	
func update_symbol():
	var symbol_center = symbol_object.get_center()
	var symbol_size = symbol_object.get_size()
	
	# area set (for click picking)
	area.global_position = symbol_center
	area.scale = symbol_size
	area.rotation = deg_to_rad(symbol_object.get_godot_degree())
	
	# draw set (rect draw)
	var size = symbol_size
	var color = symbol_object.color
	var width = Config.DEFAULT_LINE_WIDTH
	static_symbol_draw.global_position = symbol_center
	static_symbol_draw.rotation = deg_to_rad(symbol_object.get_godot_degree())
	static_symbol_draw.update_draw(size,color,width)
	

func _input(event):
	if event is InputEventMouseButton and (event.button_index == MOUSE_BUTTON_LEFT or event.button_index == MOUSE_BUTTON_RIGHT):
		if event.is_pressed() and on_cursor:
			report_static_selected.emit(self)
			
			
func _on_area_2d_mouse_entered():
	on_cursor = true


func _on_area_2d_mouse_exited():
	on_cursor = false


## --- selected(received)
#func _update_label_visibility(xml_data: XMLData):
	## because of diff, label visibility is overrided for each symbol
	#if xml_data.symbol_objects.has(symbol_object):
		#static_label.visible = xml_data.is_show_label



	
