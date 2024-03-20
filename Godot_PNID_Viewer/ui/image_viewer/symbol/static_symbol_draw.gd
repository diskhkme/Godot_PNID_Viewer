extends Node2D

var size
var color
var line_width

func _ready():
	add_to_group("draw_group")
	
	
func on_redraw_requested():
	queue_redraw()


func update_draw(size:Vector2, color:Color, line_width:float):
	self.size = size
	self.color = color
	self.line_width = line_width
	

func _draw(): # draw with size (position and rotation is applied to node2d)
	var zoom_level = get_viewport().get_camera_2d().zoom
	draw_rect(Rect2(-size.x/2,-size.y/2, size.x, size.y), color, false, line_width/zoom_level.x)
	if Config.SHOW_ROTATION_LINE:
		draw_line(Vector2(0,-size.y/2), Vector2(0, -size.y/2-size.y/3), color, line_width/zoom_level.x)

