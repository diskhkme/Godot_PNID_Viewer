# Static symbol display
# draw symbols not in editing state

extends Node2D
class_name StaticSymbolDisplay

# signal to symbol scene
signal report_selected(obj: SymbolObject)

var xml_id: int
var symbol_object: SymbolObject
var global_rect: Rect2 # for simple mouse picking

var is_editing: bool = false
var editor_handle

func _ready():
	global_rect = symbol_object.bndbox_to_rect()
	# because of rotation, node should be positioned in world space
	global_position = symbol_object.get_center()
	global_rotation_degrees = symbol_object.degree
	
	SymbolManager.symbol_selected_from_tree.connect(on_symbol_selected)
	SymbolManager.symbol_selected_from_image.connect(on_symbol_selected)
	SymbolManager.symbol_deselected.connect(on_symbol_deselected) 
	

func _draw():
	if !is_editing: 
		var rect_size = global_rect.size
		var color = ProjectManager.active_project.xml_status[xml_id].color
		draw_rect(Rect2(-rect_size.x/2, -rect_size.y/2, rect_size.x, rect_size.y), color, false, Config.DEFAULT_LINE_WIDTH)


func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			var global_mouse_pos = get_global_mouse_position()
			if global_rect.has_point(global_mouse_pos) == true: # TODO: cannot detect rotated symbol selection
				report_selected.emit(self)
			
			
func on_symbol_selected(xml_id:int, symbol_id: int) -> void:
	if self.xml_id == xml_id and self.symbol_object.id == symbol_id:
		is_editing = true
	else:
		is_editing = false
		
	queue_redraw()


func on_symbol_deselected() -> void:
	is_editing = false
	queue_redraw()
	
