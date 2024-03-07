# --- Main scene
# Controls open, close, change of project

extends Node

@onready var main_menu: Control = $CanvasLayer/MainWindow/MainMenu
@onready var image_viewer: Control = $CanvasLayer/MainWindow/Middle/ImageViewer
@onready var project_viewer: Control = $CanvasLayer/MainWindow/Middle/RightSide/ProjectViewer
@onready var xml_viewer: Control = $CanvasLayer/MainWindow/Middle/RightSide/XMLTreeViewer

@onready var type_change_window = $CanvasLayer/Dialogs/TypeChangeWindow

func _ready():
	main_menu.file_opened.connect(on_new_project)
	xml_viewer.request_type_change_window.connect(on_type_change)
	type_change_window.type_change_window_closed.connect(on_type_chan_window_closed)


func on_new_project(paths: PackedStringArray) -> void:
	var project: Project = ProjectManager.add_project(paths)
	if project != null: # TODO: fail case dialog
		make_project_active(project)
		
		
func on_type_change(xml_stat:XML_Status, symbol_object:SymbolObject):
	type_change_window.show_type_change_window(xml_stat, symbol_object)


func make_project_active(project: Project) -> void:
	ProjectManager.make_project_active(project)
	
	image_viewer.use_project(project)
	project_viewer.use_project(project)
	xml_viewer.use_project(project)
	
	# make menubar adds new tab
	
	
func on_type_chan_window_closed():
	image_viewer.grab_focus() # TODO: remove focus of tree item when window closed
	

