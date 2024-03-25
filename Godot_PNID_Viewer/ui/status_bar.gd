extends PanelContainer

@onready var camera_position_label = $MarginContainer/HBoxContainer/Left/CameraPositionLabel
@onready var camera_zoom_label = $MarginContainer/HBoxContainer/Left/CameraZoomLabel

func update_camera_position(pos: Vector2):
	camera_position_label.text = "Position: [%d, %d]" % [pos.x, pos.y]
	
	
func update_camera_zoom(zoom: float):
	camera_zoom_label.text = "Zoom: [%.2f]" % zoom
