extends Camera2D
class_name ImageViewCamera

signal zoom_changed(zoom: float)
signal moved(pos: Vector2)

var is_dragging: bool = false

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
				zoom_changed.emit(self.zoom.x)
			if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				var target_zoom = self.zoom * Config.CAMERA_ZOOM_TICK
				self.zoom -= target_zoom
				zoom_changed.emit(self.zoom.x)


	if event is InputEventMouseMotion and is_dragging:
		self.global_translate((-event.relative)/self.zoom)
		moved.emit(self.global_position)


func set_cam_position(pos: Vector2):
	global_position = pos
	moved.emit(self.global_position)


func try_focus_point(point: Vector2):
	if _is_point_in_view(point):
		return
		
	global_position = point
	moved.emit(self.global_position)


func _is_point_in_view(point: Vector2):
	var camera_pos = global_position
	var cam_center_to_symbol = point - camera_pos
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



