extends Node2D

var _size
var _color
var _line_width

func update_draw(size:Vector2, color:Color, line_width:float):
	_size = size
	_color = color
	_line_width = line_width


func _draw(): # draw with _size (position and rotation is applied to node2d)
	var zoom_level = get_viewport().get_camera_2d().zoom
	draw_rect(Rect2(-_size.x/2,-_size.y/2, _size.x, _size.y), _color, false, _line_width/zoom_level.x)
	if Config.SHOW_ROTATION_LINE:
		draw_line(Vector2(0,-_size.y/2), Vector2(0, -_size.y/2-_size.y/3), _color, _line_width/zoom_level.x)

