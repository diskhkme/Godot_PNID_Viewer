# image interaction
# zoom, pan image of image viewer

extends Node
class_name ImageInteraction

signal zoom_changed(zoom_level: float)

@export var image_view_cam: Camera2D

var is_locked: bool = false
var is_dragging: bool = false
var drag_start_position: Vector2
var drag_offset: Vector2

func _ready():
	add_to_group("draw_group")
	

func _input(event):
	if is_locked:
		return
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		if not is_dragging and event.is_pressed():
			is_dragging = true

		if is_dragging and event.is_released():
			is_dragging = false

	if event is InputEventMouseMotion and is_dragging:
		image_view_cam.global_translate((-event.relative)/image_view_cam.zoom)
		
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_WHEEL_UP:
		var target_zoom = image_view_cam.zoom * Config.CAMERA_ZOOM_TICK
		image_view_cam.zoom += target_zoom
		get_tree().call_group("draw_group", "on_redraw_requested")
		
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
		var target_zoom = image_view_cam.zoom * Config.CAMERA_ZOOM_TICK
		image_view_cam.zoom -= target_zoom
		get_tree().call_group("draw_group", "on_redraw_requested")
