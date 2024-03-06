extends Node2D

var size
var color
var line_width

var removed = false

func _ready():
	add_to_group("draw_group")
	
	
func on_redraw_requested():
	queue_redraw()


func update_draw(size:Vector2, color:Color, line_width:float, removed: bool):
	self.size = size
	self.color = color
	self.line_width = line_width
	self.removed = removed

func _draw(): # draw with size (position and rotation is applied to node2d)
	if removed:
		return
		
	var zoom_level = get_viewport().get_camera_2d().zoom
	draw_rect(Rect2(-size.x/2,-size.y/2, size.x, size.y), color, false, line_width/zoom_level.x)

