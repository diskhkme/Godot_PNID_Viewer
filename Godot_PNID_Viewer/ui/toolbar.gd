extends HBoxContainer

signal add_xml
signal export_image
signal undo_action
signal redo_action

@onready var add_xml_button = $HBoxContainer/AddXMLButton
@onready var undo_button = $HBoxContainer/UndoButton
@onready var redo_button = $HBoxContainer/RedoButton
@onready var export_img_button = $HBoxContainer/ExportImageButton
@onready var fullscreen_button = $HBoxContainer3/FullScreenButton

func _ready():
	add_xml_button.disabled = true
	undo_button.disabled = true
	redo_button.disabled = true
	export_img_button.disabled = true
	if OS.get_name() == "Web":
		fullscreen_button.free()
	
	
func _process(delta):
	_update_button_enabled()
	

func _on_add_xml_button_pressed():
	add_xml.emit()

func _on_export_image_button_pressed():
	export_image.emit()

		
func _on_undo_button_pressed():
	undo_action.emit()


func _on_redo_button_pressed():
	redo_action.emit()
	
	
func _on_full_screen_button_pressed():
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)


func _update_button_enabled():
	if ProjectManager.active_project == null:
		add_xml_button.disabled = true
		export_img_button.disabled = true
	else:
		add_xml_button.disabled = false
		export_img_button.disabled = false
		
		if ProjectManager.active_project.has_undo():
			undo_button.disabled = false
		else:
			undo_button.disabled = true
			
		if ProjectManager.active_project.has_redo():
			redo_button.disabled = false
		else:
			redo_button.disabled = true



