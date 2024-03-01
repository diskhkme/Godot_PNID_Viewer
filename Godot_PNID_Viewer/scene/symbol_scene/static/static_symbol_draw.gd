extends Node2D

var size
var color
var line_width

func update_draw(size:Vector2, color:Color, line_width:float):
	self.size = size
	self.color = color
	self.line_width = line_width


func _draw(): # draw with size (position and rotation is applied to node2d)
	draw_rect(Rect2(-size.x/2,-size.y/2, size.x, size.y), color, false, line_width)
	pass
