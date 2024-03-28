# --- Main scene
# Controls open, close, change of project

extends Node

# top section
@onready var _main_menu: Control = $CanvasLayer/MainWindow/MainMenu
@onready var _toolbar: Control = $CanvasLayer/MainWindow/Toolbar
# middle section
@onready var _image_viewer: Control = $CanvasLayer/MainWindow/Middle/ImageViewer
@onready var _project_viewer: Control = $CanvasLayer/MainWindow/Middle/RightSide/ProjectViewer
@onready var _xml_tree_viewer: Control = $CanvasLayer/MainWindow/Middle/RightSide/XMLTreeViewer
# bottom section
@onready var _status_bar: Control = $CanvasLayer/MainWindow/StatusBar

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
	Util.print_log = false
	
	# Signal
	DataLoader.project_files_opened.connect(_on_project_files_opened)
	DataLoader.xml_files_opened.connect(_on_xml_files_opened)
	
	_main_menu.open_files.connect(_on_new_project)
	_main_menu.active_project_change.connect(_on_active_project_change)
	_main_menu.project_tab_close.connect(_on_project_close)
	
	_toolbar.add_xml.connect(_on_add_xml)
	_toolbar.export_image.connect(_on_export_img)
	_toolbar.undo_action.connect(_on_undo_action)
	_toolbar.redo_action.connect(_on_redo_action)
	
	_image_viewer.screenshot_taken.connect(_on_screenshot_taken)
	_image_viewer.symbol_selected.connect(_on_symbol_selected)
	_image_viewer.symbol_editing.connect(_on_symbol_editing)
	_image_viewer.symbol_deselected.connect(_on_symbol_deselected)
	_image_viewer.zoom_changed.connect(_on_zoom_changed)
	_image_viewer.camera_moved.connect(_on_camera_moved)
	_image_viewer_context_menu.add_symbol_pressed.connect(_on_add_symbol)
	_image_viewer_context_menu.remove_symbol_pressed.connect(_on_remove_symbol)
	_image_viewer_context_menu.edit_symbol_pressed.connect(_on_edit_symbol)
	
	_project_viewer.xml_selected.connect(_on_xml_selected)
	_project_viewer.xml_visibility_changed.connect(_on_xml_visibility_changed)
	_project_viewer.xml_selectability_changed.connect(_on_xml_selectability_changed)
	_project_viewer.xml_label_visibility_changed.connect(_on_xml_label_visibility_changed)
	_project_viewer_context_menu.xml_save_as_pressed.connect(_on_save_as_xml)
	_project_viewer_context_menu.diff_pressed.connect(_on_diff_xml)
	_project_viewer_context_menu.close_pressed.connect(_on_close_xml)
	
	_xml_tree_viewer.symbol_selected.connect(_on_symbol_selected)
	_xml_tree_viewer.symbol_deselected.connect(_on_symbol_deselected)
	
	_diff_window.diff_calc_completed.connect(_on_diff_calc_completed)
	
	_type_change_dialog.symbol_type_changed.connect(_on_symbol_type_change)
	
	# TODO: Close xml
	
func _input(event):
	if ProjectManager.active_project == null:
		return
	
	if event is InputEventMouse:
		is_context_on = _image_viewer_context_menu.visible or \
					_project_viewer_context_menu.visible
					
		if is_context_on or _image_viewer.is_editing():
			_xml_tree_viewer.set_mouse_event_process(false)
		else:
			_xml_tree_viewer.set_mouse_event_process(true)

		if !is_context_on:
			_image_viewer.process_input(event)
			_image_viewer_context_menu.process_input(event, _image_viewer.selected_symbol != null)
			if not _image_viewer.is_editing():
				_project_viewer_context_menu.process_input(event)
		else:
			if _image_viewer_context_menu.visible:
				_image_viewer_context_menu.process_input(event, _image_viewer.selected_symbol != null)
				return
			if _project_viewer_context_menu.visible:
				_project_viewer_context_menu.process_input(event)
				return
			
	if event is InputEventKey and event.is_pressed():
		if event.ctrl_pressed and event.keycode == KEY_Z:
			_on_undo_action()
		if event.ctrl_pressed and event.keycode == KEY_Y:
			_on_redo_action()
		if event.keycode == KEY_ESCAPE and _image_viewer.is_editing():
			ProjectManager.active_project.symbol_edit_canceled()
			_image_viewer.cancel_selected()
			_xml_tree_viewer.deselect_symbol()
		if event.keycode == KEY_DELETE and _image_viewer.is_editing():
			_on_remove_symbol()
			

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
	project.symbol_action.connect(_on_any_symbol_action)
	_make_project_active(project)


func _on_active_project_change(project: Project):
	_make_project_active(project)
			
		
func _make_project_active(project: Project):
	ProjectManager.make_project_active(project)
	_main_menu.add_project_tab(project) # make tab first to prevent duplicated call
	_image_viewer.use_project(project)
	_project_viewer.use_project(project)
	_xml_tree_viewer.use_project(project)
	
	
func _on_project_close(project: Project):
	_main_menu.close_project_tab(project)
	_image_viewer.close_project(project)
	_project_viewer.close_project(project)
	_xml_tree_viewer.close_project(project)
	ProjectManager.close_project(project)
	_status_bar.reset()
		
		
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
	update_guis()
	
	
func _on_close_xml():
	var xml_data = _project_viewer.selected_xml
	ProjectManager.active_project.close_xml(xml_data)
	_image_viewer.close_xml(xml_data)
	_project_viewer.close_xml(xml_data)
	_xml_tree_viewer.close_xml(xml_data)
	
	
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

	
func _on_symbol_selected(symbol_object: SymbolObject, from_tree: bool):
	if not from_tree:
		_xml_tree_viewer.select_symbol(symbol_object)
	else:
		_project_viewer.select_xml(symbol_object.source_xml)
		_image_viewer.select_symbol(symbol_object)
		ProjectManager.active_project.symbol_edit_started(symbol_object)
	
	
func _on_symbol_deselected(symbol_object: SymbolObject, from_tree: bool):
	if not from_tree:
		_xml_tree_viewer.deselect_symbol()
	else:
		ProjectManager.active_project.symbol_edited(symbol_object)
		_image_viewer.apply_symbol_change(symbol_object)
	

func _on_symbol_editing(symbol_object: SymbolObject):
	_xml_tree_viewer.apply_symbol_change(symbol_object)
		
		
func _on_add_symbol(pos: Vector2):
	var target_xml
	if _project_viewer.selected_xml != null: #if selected xml exist, add to that xml
		target_xml = _project_viewer.selected_xml
	else: #else, add to first xml
		target_xml = ProjectManager.active_project.xml_datas[0]
		
	ProjectManager.active_project.symbol_add(pos, target_xml)
	
	
func _on_remove_symbol():
	var target_symbol = _image_viewer.selected_symbol
	target_symbol.removed = true
	ProjectManager.active_project.symbol_edited(target_symbol)
	_image_viewer.cancel_selected()

	
func _on_undo_action():
	ProjectManager.active_project.undo()

	
func _on_redo_action():
	ProjectManager.active_project.redo()
	
	
func _on_any_symbol_action(target_symbol: SymbolObject):
	_image_viewer.apply_symbol_change(target_symbol)
	_xml_tree_viewer.apply_symbol_change(target_symbol)	
	_project_viewer.update_dirty()
	_main_menu.update_dirty()
	if _project_viewer.selected_xml != null:
		_status_bar.update_xml_status(_project_viewer.selected_xml)
	
	
func update_guis():
	_image_viewer.use_project(ProjectManager.active_project)
	_project_viewer.use_project(ProjectManager.active_project)
	_xml_tree_viewer.use_project(ProjectManager.active_project)
	
	
func _on_xml_selected(xml_data: XMLData):
	_xml_tree_viewer.scroll_to_xml(xml_data)
	_status_bar.update_xml_status(xml_data)
	
	
func _on_save_as_xml():
	if OS.get_name() == "Windows":
		if not _save_as_dialog.file_selected.is_connected(_project_viewer.save_xml):
			_save_as_dialog.file_selected.connect(_project_viewer.save_xml)
		_save_as_dialog.popup_centered()
	elif OS.get_name() == "Web":
		var xml_dump = PnidXmlIo.dump_pnid_xml(_project_viewer.selected_xml.symbol_objects)
		JavaScriptBridge.download_buffer(xml_dump.to_utf8_buffer(), "export.xml")


func _on_xml_visibility_changed(xml_data: XMLData, is_text: bool, enabled: bool):
	if is_text:
		xml_data.is_text_visible = enabled
	else:
		xml_data.is_symbol_visible = enabled
	_image_viewer.update_xml_visibility(xml_data)
	_xml_tree_viewer.update_xml_visibility(xml_data)
	

func _on_xml_selectability_changed(xml_data: XMLData, enabled: bool):
	xml_data.is_selectable = enabled
	# for imageviewer, selection filter itself checks selectability of xml_data
	_xml_tree_viewer.update_xml_selectability(xml_data)


func _on_xml_label_visibility_changed(xml_data: XMLData, enabled: bool):
	xml_data.is_show_label = enabled
	_image_viewer.update_label_visibility(xml_data)


func _on_diff_xml():
	_diff_window.popup_centered()
	_diff_window.initialize_with_selected(_project_viewer.selected_xml)
	
	
func _on_diff_calc_completed(symbol_objects, diff_name, source_xml, target_xml):
	ProjectManager.active_project.add_diff_xml(symbol_objects, diff_name, source_xml, target_xml)
	update_guis()


func _show_type_change_window(symbol_object:SymbolObject):
	_type_change_dialog.show_type_change_window(symbol_object)


func _on_zoom_changed(zoom: float):
	_status_bar.update_camera_zoom(zoom)
	
	
func _on_camera_moved(pos: Vector2):
	_status_bar.update_camera_position(pos)
	
	
func _on_edit_symbol():
	_type_change_dialog.initialize_types(_xml_tree_viewer.selected_symbol)
	_type_change_dialog.popup_centered()
	
	
func _on_symbol_type_change(symbol_object: SymbolObject):
	_xml_tree_viewer.apply_symbol_change(symbol_object)
	
	
