# --- Main scene
# Controls open, close, change of project

extends Node

@onready var main_menu: Control = $CanvasLayer/MainWindow/MainMenu
@onready var image_viewer: Control = $CanvasLayer/MainWindow/Middle/ImageViewer
@onready var image_view_camera = $CanvasLayer/MainWindow/Middle/ImageViewer/SubViewportContainer/SubViewport/ImageViewCamera
@onready var project_viewer: Control = $CanvasLayer/MainWindow/Middle/RightSide/ProjectViewer
@onready var xml_viewer: Control = $CanvasLayer/MainWindow/Middle/RightSide/XMLTreeViewer

@onready var type_change_window = $CanvasLayer/Dialogs/TypeChangeWindow
@onready var image_viewer_context_menu = $CanvasLayer/ContextMenus/ImageViewContextMenu
@onready var project_viewer_context_menu = $CanvasLayer/ContextMenus/ProjectViewContextMenu

var is_context_on = false

func _ready():
	if OS.get_name() == "Windows":
		# for windows, start new project if dialog closed
		main_menu.file_opened.connect(on_new_project)
	if OS.get_name() == "Web":
		# for web, start new project if dataloader signaled
		DataLoader.file_opened.connect(on_new_project)
		
		
	main_menu.active_project_changed.connect(on_changed_active_project)
	xml_viewer.request_type_change_window.connect(on_type_change)
	
	
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
			
			

func on_new_project(args: Variant): # web & windows
	var project: Project = ProjectManager.add_project(args)
	if project != null: # TODO: fail case dialog
		main_menu.add_project_tab(project)
		
		
func on_type_change(xml_stat:XML_Status, symbol_object:SymbolObject):
	type_change_window.show_type_change_window(xml_stat, symbol_object)


func make_project_active(project: Project) -> void:
	ProjectManager.make_project_active(project)
	
	image_viewer.use_project(project)
	project_viewer.use_project(project)
	xml_viewer.use_project(project)
	

# TODO: create visibility/selectability signal to Project and
# watch it from who is responsible (not image_viewer but symbolscene, etc)
#func on_xml_visibility_changed(xml_id: int):
	#image_viewer.change_visibility(xml_id)
	#xml_viewer.change_visibility(xml_id)
	#
	#
#func on_xml_selectabilty_changed(xml_id: int):
	#xml_viewer.change_selectability(xml_id)
	
	
func on_changed_active_project(project: Project):
	make_project_active(project)
	

