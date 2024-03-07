extends Camera2D
class_name ImageViewCamera

func _ready():
	SymbolManager.symbol_selected_from_tree.connect(focus_symbol)


func focus_symbol(xml_id:int, symbol_id:int):
	var target_symbol = ProjectManager.get_symbol_in_xml(xml_id, symbol_id)
	if is_symbol_visible(target_symbol):
		return
		
	global_position = target_symbol.get_center()


func is_symbol_visible(target_symbol: SymbolObject):
	var camera_pos = global_position
	var symbol_center = target_symbol.get_center()
	var cam_center_to_symbol = symbol_center - camera_pos
	var visible_rect = get_viewport().get_visible_rect()
	visible_rect.size /= zoom.x
	if visible_rect.size.x*0.5 - abs(cam_center_to_symbol.x) > 0 and visible_rect.size.y*0.5 - abs(cam_center_to_symbol.y) > 0:
	#if visible_rect.has_point(cam_center_to_symbol):
		return true
		
	return false


func get_pixel_from_image_canvas(canvas_coord: Vector2):
	var visible_rect = get_viewport().get_visible_rect()
	visible_rect.size /= zoom.x
	var camera_pos = global_position
	var topleft = camera_pos - visible_rect.size*0.5
	return topleft + canvas_coord / zoom.x
