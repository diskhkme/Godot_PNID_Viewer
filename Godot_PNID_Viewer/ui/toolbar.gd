extends HBoxContainer

@export var add_xml_dialog: FileDialog
@export var save_img_dialog: FileDialog

var screenshot_path

func _ready():
	if OS.get_name() == "Windows":
		# for windows, start new project if dialog closed
		add_xml_dialog.files_selected.connect(_on_xml_files_selected)
		save_img_dialog.file_selected.connect(_on_save_image_file)
	if OS.get_name() == "Web":
		# for web, start new project if dataloader signaled
		DataLoader.xml_files_opened.connect(_add_xml_to_project)
		
	SignalManager.screenshot_taken.connect(_on_screenshot_taken)


func _on_add_xml_button_pressed():
	if OS.get_name() == "Windows":
		add_xml_dialog.popup()
	elif OS.get_name() == "Web":
		var window = JavaScriptBridge.get_interface("window")
		window.input_xml.click()


func _on_xml_files_selected(paths):
	var args = DataLoader.xml_files_load_from_paths(paths)
	_add_xml_to_project(args)
	
	
func _add_xml_to_project(args):
	var num_xml = args[0]
	var xml_filenames = args[1]
	var xml_str = args[2]
	
	ProjectManager.active_project.add_xml_from_file(num_xml, xml_filenames, xml_str)


func _on_export_image_button_pressed():
	if OS.get_name() == "Windows":
		save_img_dialog.popup()
	if OS.get_name() == "Web":
		SignalManager.screenshot_requested.emit()

	
func _on_save_image_file(path):
	screenshot_path = path
	SignalManager.screenshot_requested.emit()
		
		
func _on_undo_button_pressed():
	ProjectManager.active_project.undo_redo.undo()


func _on_redo_button_pressed():
	ProjectManager.active_project.undo_redo.redo()


func _on_screenshot_taken(img: Image):
	if OS.get_name() == "Windows":
		if !screenshot_path.contains(".png"):
			screenshot_path += ".png"
		img.save_png(screenshot_path)
	if OS.get_name() == "Web":
		var data = img.save_png_to_buffer()
		JavaScriptBridge.download_buffer(data, "Screenshot.png", "image/png")
