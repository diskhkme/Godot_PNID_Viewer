extends HBoxContainer


@export var add_xml_dialog: FileDialog

func _ready():
	if OS.get_name() == "Windows":
		# for windows, start new project if dialog closed
		add_xml_dialog.files_selected.connect(on_xml_files_selected)
	if OS.get_name() == "Web":
		# for web, start new project if dataloader signaled
		DataLoader.xml_files_opened.connect(add_xml_to_project)


func _on_add_xml_button_pressed():
	if OS.get_name() == "Windows":
		add_xml_dialog.popup()
	elif OS.get_name() == "Web":
		var window = JavaScriptBridge.get_interface("window")
		window.input_xml.click()


func on_xml_files_selected(paths):
	var args = DataLoader.xml_files_load_from_paths(paths)
	add_xml_to_project(args)
	
	
func add_xml_to_project(args):
	var num_xml = args[0]
	var xml_filenames = args[1]
	var xml_str = args[2]
	
	ProjectManager.active_project.add_xml_from_file(num_xml, xml_filenames, xml_str)

