# --- Main scene
# Controls open, close, change of project

extends Node

@onready var main_menu: Control = $CanvasLayer/MainWindow/MainMenu
@onready var image_viewer: Control = $CanvasLayer/MainWindow/Middle/ImageViewer
@onready var image_view_camera = $CanvasLayer/MainWindow/Middle/ImageViewer/SubViewportContainer/SubViewport/ImageViewCamera
@onready var project_viewer: Control = $CanvasLayer/MainWindow/Middle/RightSide/ProjectViewer
@onready var xml_viewer: Control = $CanvasLayer/MainWindow/Middle/RightSide/XMLTreeViewer

# TODO: handover dialog control to xml viewer
@onready var type_change_dialog = $CanvasLayer/Dialogs/TypeChangeWindow
#@onready var diff_window = $CanvasLayer/Dialogs/DiffWindow

@onready var image_viewer_context_menu = $CanvasLayer/ContextMenus/ImageViewContextMenu
@onready var project_viewer_context_menu = $CanvasLayer/ContextMenus/ProjectViewContextMenu

var is_context_on = false

func _ready():
	if OS.get_name() == "Windows":
		# for windows, start new project if dialog closed
		main_menu.file_opened.connect(_add_project)
	if OS.get_name() == "Web":
		# for web, start new project if dataloader signaled
		DataLoader.file_opened.connect(_add_project)
		
		
	main_menu.active_project_changed.connect(_on_changed_active_project)
	xml_viewer.request_type_change_window.connect(_show_type_change_window)
	
	SignalManager.xml_added.connect(_on_xml_added)
	
	
func _input(event):
	if event is InputEventMouse:
		is_context_on = image_viewer_context_menu.visible or project_viewer_context_menu.visible
		
		if !is_context_on:
			image_viewer.process_input(event)
		
		# TODO: Exclusive context popup
		if image_viewer.get_global_rect().has_point(event.position):
			image_viewer_context_menu.process_input(event)
		elif project_viewer.get_global_rect().has_point(event.position):
			project_viewer_context_menu.process_input(event)
			
			

func _add_project(args: Variant): # web & windows
	var project: Project = ProjectManager.add_project(args)
	if project != null: # TODO: fail case dialog
		main_menu.add_project_tab(project)
		
		
func _show_type_change_window(symbol_object:SymbolObject):
	type_change_dialog.show_type_change_window(symbol_object)


func _on_xml_added(xml_data: XMLData):
	# Just re-initialize everything
	image_viewer.use_project(ProjectManager.active_project)
	project_viewer.use_project(ProjectManager.active_project)
	xml_viewer.use_project(ProjectManager.active_project)


func make_project_active(project: Project):
	ProjectManager.make_project_active(project)
	image_viewer.use_project(project)
	project_viewer.use_project(project)
	xml_viewer.use_project(project)

	
func _on_changed_active_project(project: Project):
	make_project_active(project)
	
	

