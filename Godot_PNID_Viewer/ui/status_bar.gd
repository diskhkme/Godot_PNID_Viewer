extends PanelContainer

@onready var camera_position_label = $MarginContainer/HBoxContainer/Left/CameraPositionLabel
@onready var camera_zoom_label = $MarginContainer/HBoxContainer/Left/CameraZoomLabel
@onready var count_label = $MarginContainer/HBoxContainer/Right/CountLabel
@onready var edit_label = $MarginContainer/HBoxContainer/Right/EditLabel

func _ready():
	reset()
	
	
func reset():
	update_camera_position(Vector2.ZERO)
	update_camera_zoom(1.0)
	count_label.text = "Symbol:0 (Sym)0 (Text)0"
	edit_label.text = "Edit:0 Add:0 Remove:0"


func update_camera_position(pos: Vector2):
	camera_position_label.text = "Position: [%d, %d]" % [pos.x, pos.y]
	
	
func update_camera_zoom(zoom: float):
	camera_zoom_label.text = "Zoom: [%d" % (zoom * 100) + "%]"


func update_xml_status(xml_data: XMLData):
	var total = xml_data.symbol_objects.size()
	var text_count = xml_data.symbol_objects.filter(func(s): return s.is_text).size()
	var symbol_count = total - text_count
	count_label.text = "Symbol:%d (Sym)%d (Text)%d" % [total, symbol_count, text_count]
	
	var dirty_count = xml_data.symbol_objects.filter(func(s): return s.dirty).size()
	var rmv_count = xml_data.symbol_objects.filter(func(s): return s.removed).size()
	var add_count = xml_data.symbol_objects.filter(func(s): return s.is_new).size()
	var edit_count = dirty_count - rmv_count - add_count
	edit_label.text = "Edit:%d Add:%d Remove:%d" % [edit_count, add_count, rmv_count]
