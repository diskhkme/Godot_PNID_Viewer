extends Camera2D
class_name ImageViewCamera

signal zoom_changed(zoom_level: float)

var is_dragging: bool = false

func _ready():
	add_to_group("draw_group")
	SymbolManager.symbol_selected_from_tree.connect(_focus_symbol)


func process_input(event):
	if event is InputEventMouseButton:
		# panning
		if event.button_index == MOUSE_BUTTON_RIGHT: 
			if not is_dragging and event.is_pressed():
				is_dragging = true
			if is_dragging and event.is_released():
				is_dragging = false
		
		# zooming
		if !get_viewport().get_visible_rect().has_point(event.position): # no zoom outside viewport
			return
		else:
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				var target_zoom = self.zoom * Config.CAMERA_ZOOM_TICK
				self.zoom += target_zoom
				get_tree().call_group("draw_group", "on_redraw_requested")
			if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				var target_zoom = self.zoom * Config.CAMERA_ZOOM_TICK
				self.zoom -= target_zoom
				get_tree().call_group("draw_group", "on_redraw_requested")

	if event is InputEventMouseMotion and is_dragging:
		self.global_translate((-event.relative)/self.zoom)


func _focus_symbol(symbol_object: SymbolObject):
	if is_symbol_visible(symbol_object):
		return
		
	global_position = symbol_object.get_center()


func is_symbol_visible(target_symbol: SymbolObject):
	var camera_pos = global_position
	var symbol_center = target_symbol.get_center()
	var cam_center_to_symbol = symbol_center - camera_pos
	var visible_rect = get_viewport().get_visible_rect()
	visible_rect.size /= zoom.x
	if visible_rect.size.x*0.5 - abs(cam_center_to_symbol.x) > 0 and visible_rect.size.y*0.5 - abs(cam_center_to_symbol.y) > 0:
		return true
		
	return false


func get_pixel_from_image_canvas(canvas_coord: Vector2):
	var visible_rect = get_viewport().get_visible_rect()
	visible_rect.size /= zoom.x
	var camera_pos = global_position
	var topleft = camera_pos - visible_rect.size*0.5
	return topleft + canvas_coord / zoom.x



