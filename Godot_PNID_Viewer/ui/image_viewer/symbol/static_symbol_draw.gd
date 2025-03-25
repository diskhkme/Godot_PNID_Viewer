extends Node2D

var symbol_object

func _init():
	add_to_group("draw")
	
	
func redraw():
	queue_redraw()
	

func _draw():
	var _size = symbol_object.get_size()
	var _color = symbol_object.origin_xml.color
	var _line_width = Config.DEFAULT_LINE_WIDTH
	
	var zoom_factor = get_viewport().get_camera_2d().zoom.x
	draw_rect(Rect2(-_size.x/2,-_size.y/2, _size.x, _size.y), _color, false, _line_width/zoom_factor)
	if Config.SHOW_ROTATION_LINE:
		draw_line(Vector2(0,-_size.y/2), Vector2(0, -_size.y/2-_size.y/3), _color, _line_width/zoom_factor)

