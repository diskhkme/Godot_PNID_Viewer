extends Window

signal color_changed(color: Color)
signal color_picker_closed

@onready var color_picker = $ColorPicker

func initialize_color(xml_color: Color):
	color_picker.color = xml_color


func _on_color_picker_color_changed(color):
	color_changed.emit(color)


func _on_close_requested():
	color_picker_closed.emit()
	visible = false
