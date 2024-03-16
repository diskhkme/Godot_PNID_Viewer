extends Control

@export var project_viewer: ProjectViewer
@export var save_file_dialog: FileDialog
@export var diff_dialog: DiffDialog

@onready var save_as_button = $PanelContainer/VBoxContainer/SaveAsButton

var is_in_context_menu: bool

func _ready():
	save_file_dialog.file_selected.connect(_on_save_path_selected)
	

func process_input(event):
	reset_size()
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		if !event.is_pressed() and !visible and project_viewer.selected_xml != null:
			position = event.position
			visible = true
			
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if !is_in_context_menu:
			visible = false


func _on_save_as_button_pressed():
	assert(project_viewer.selected_xml != null, "No XML Selected for export")
	
	if OS.get_name() == "Windows":
		save_file_dialog.popup()
	elif OS.get_name() == "Web":
		var xml_dump = PnidXmlIo.dump_pnid_xml(project_viewer.selected_xml.symbol_objects)
		JavaScriptBridge.download_buffer(xml_dump.to_utf8_buffer(), "export.xml")

	visible = false


func _on_diff_button_pressed():
	diff_dialog.popup()
	diff_dialog.initialize_with_selected(project_viewer.selected_xml)
	visible = false
	
	
func _on_save_path_selected(path: String):
	if !path.contains(".xml"):
		path += ".xml"
		
	var xml_dump = PnidXmlIo.dump_pnid_xml(project_viewer.selected_xml.symbol_objects)
	if OS.get_name() == "Windows":
		var file = FileAccess.open(path, FileAccess.WRITE)
		file.store_string(xml_dump)


func _on_mouse_entered():
	is_in_context_menu = true


func _on_mouse_exited():
	is_in_context_menu = false
