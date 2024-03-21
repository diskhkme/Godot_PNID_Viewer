# --- Main scene
# Controls open, close, change of project

extends Node

# top section
@onready var _main_menu: Control = $CanvasLayer/MainWindow/MainMenu
@onready var _toolbar: Control = $CanvasLayer/MainWindow/Toolbar
# middle section
@onready var _image_viewer: Control = $CanvasLayer/MainWindow/Middle/ImageViewer
@onready var _project_viewer: Control = $CanvasLayer/MainWindow/Middle/RightSide/ProjectViewer
@onready var _xml_viewer: Control = $CanvasLayer/MainWindow/Middle/RightSide/XMLTreeViewer
# bottom section
#@onready var status_bar: Control = $CanvasLayer/MainWindow/StatusBar_TODO

# dialogs
@onready var _new_project_dialog = $CanvasLayer/Dialogs/NewProjectDialog
@onready var _add_xml_dialog = $CanvasLayer/Dialogs/AddXMLDialog
@onready var _save_as_dialog = $CanvasLayer/Dialogs/SaveAsFilesDialog
@onready var _save_img_dialog = $CanvasLayer/Dialogs/SaveImageDialog
@onready var _type_change_dialog = $CanvasLayer/Dialogs/TypeChangeWindow
@onready var _diff_window = $CanvasLayer/Dialogs/DiffWindow

# context menu
@onready var _image_viewer_context_menu = $CanvasLayer/ContextMenus/ImageViewContextMenu
@onready var _project_viewer_context_menu = $CanvasLayer/ContextMenus/ProjectViewContextMenu

var is_context_on = false

func _ready():
	# Init?
	
	
	# Signal
	DataLoader.project_files_opened.connect(_on_project_files_opened)
	DataLoader.xml_files_opened.connect(_on_xml_files_opened)
	
	_main_menu.open_files.connect(_on_new_project)
	_main_menu.active_project_change.connect(_on_active_project_change)
	_main_menu.project_tab_close.connect(_on_project_close)
	
	_toolbar.add_xml.connect(_on_add_xml)
	_toolbar.export_image.connect(_on_export_img)
	#_toolbar.undo_action.connect() # TODO
	#_toolbar.redo_action.connect()
	
	_image_viewer.screenshot_taken.connect(_on_screenshot_taken)
	
		
	_xml_viewer.request_type_change_window.connect(_show_type_change_window)
	
	
	
func _input(event):
	if ProjectManager.active_project == null:
		return
	
	if event is InputEventMouse:
		is_context_on = _image_viewer_context_menu.visible or _project_viewer_context_menu.visible
		
		if !is_context_on:
			_image_viewer.process_input(event)
		
		# TODO: Exclusive context popup
		if _image_viewer.get_global_rect().has_point(event.position):
			_image_viewer_context_menu.process_input(event)
		elif _project_viewer.get_global_rect().has_point(event.position):
			_project_viewer_context_menu.process_input(event)
			
			

func _on_new_project(): # web & windows
	if OS.get_name() == "Windows":
		if not _new_project_dialog.files_selected.is_connected(DataLoader.project_files_load_from_paths):
			_new_project_dialog.files_selected.connect(DataLoader.project_files_load_from_paths)
		_new_project_dialog.popup_centered()
	elif OS.get_name() == "Web":
		var _window = JavaScriptBridge.get_interface("window")
		_window.input.click()
	
	
func _on_project_files_opened(args):
	var project: Project = ProjectManager.add_project(args)
	_make_project_active(project)


func _on_active_project_change(project: Project):
	_make_project_active(project)
			
		
func _make_project_active(project: Project):
	ProjectManager.make_project_active(project)
	_main_menu.add_project_tab(project) # make tab first to prevent duplicated call
	_image_viewer.use_project(project)
	_project_viewer.use_project(project)
	_xml_viewer.use_project(project)
	
	
func _on_project_close(project: Project):
	if project.dirty:
		pass # TODO: check dialog
	else:	
		_main_menu.close_project_tab(project)
		_image_viewer.close_project(project)
		ProjectManager.close_project(project)
		
		
func _on_add_xml():
	if OS.get_name() == "Windows":
		if not _add_xml_dialog.files_selected.is_connected(DataLoader.xml_files_load_from_paths):
			_add_xml_dialog.files_selected.connect(DataLoader.xml_files_load_from_paths)
		_add_xml_dialog.popup_centered()
	elif OS.get_name() == "Web":
		var _window = JavaScriptBridge.get_interface("window")
		_window.input_xml.click()


func _on_xml_files_opened(args):
	var num_xml = args[0]
	var xml_filenames = args[1]
	var xml_str = args[2]
	ProjectManager.active_project.add_xmls(num_xml, xml_filenames, xml_str)
	_image_viewer.update_xml(ProjectManager.active_project)
	_project_viewer.use_project(ProjectManager.active_project)
	_xml_viewer.use_project(ProjectManager.active_project)
	
	
func _on_export_img():
	if OS.get_name() == "Windows":
		if not _save_img_dialog.file_selected.is_connected(_image_viewer.generate_screenshot):
			_save_img_dialog.file_selected.connect(_image_viewer.generate_screenshot)
		_save_img_dialog.popup_centered()
	elif OS.get_name() == "Web":
		_image_viewer.generate_screenshot("") # no path required for web


func _on_screenshot_taken(img: Image, path: String):
	if OS.get_name() == "Windows":
		if !path.contains(".png"):
			path += ".png"
		img.save_png(path)
	if OS.get_name() == "Web":
		var data = img.save_png_to_buffer()
		JavaScriptBridge.download_buffer(data, "Screenshot.png", "image/png")

	img.free()
	
	

func _show_type_change_window(symbol_object:SymbolObject):
	_type_change_dialog.show_type_change_window(symbol_object)



	

	
	

