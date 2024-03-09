# --- Main scene
# Controls open, close, change of project

extends Node

@onready var main_menu: Control = $CanvasLayer/MainWindow/MainMenu
@onready var image_viewer: Control = $CanvasLayer/MainWindow/Middle/ImageViewer
@onready var image_view_camera = $CanvasLayer/MainWindow/Middle/ImageViewer/SubViewportContainer/SubViewport/ImageViewCamera
@onready var image_viewer_context_menu = $CanvasLayer/MainWindow/Middle/ImageViewer/ContextMenu/ImageViewContextMenu
@onready var project_viewer: Control = $CanvasLayer/MainWindow/Middle/RightSide/ProjectViewer
@onready var xml_viewer: Control = $CanvasLayer/MainWindow/Middle/RightSide/XMLTreeViewer

@onready var type_change_window = $CanvasLayer/Dialogs/TypeChangeWindow

func _ready():
	main_menu.file_opened.connect(on_new_project)
	xml_viewer.request_type_change_window.connect(on_type_change)
	
	image_viewer_context_menu.context_add_clicked.connect(on_add_symbol)
	image_viewer_context_menu.context_remove_clicked.connect(on_remove_symbol)
	
	project_viewer.xml_visibility_changed.connect(on_xml_visibility_changed)
	project_viewer.xml_selectability_changed.connect(on_xml_selectabilty_changed)


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
	

func on_xml_visibility_changed(xml_id: int):
	image_viewer.change_visibility(xml_id)
	xml_viewer.change_visibility(xml_id)
	
	
func on_xml_selectabilty_changed(xml_id: int):
	image_viewer.change_selectability(xml_id)
	xml_viewer.change_selectability(xml_id)
	

func on_add_symbol(pos: Vector2):
	var pos_in_image = image_view_camera.get_pixel_from_image_canvas(pos)
	var new_symbol_id = ProjectManager.active_project.xml_status[0].add_new_symbol(pos_in_image) # TODO: how to set target xml?
	SymbolManager.symbol_selected_from_image.emit(0, new_symbol_id)	
	SymbolManager.symbol_edit_started.emit(0, new_symbol_id)
	
	
func on_remove_symbol():
	var xml_id = SymbolManager.selected_xml_id
	var symbol_id = SymbolManager.selected_symbol_id
	ProjectManager.active_project.xml_status[xml_id].remove_symbol(symbol_id)
	SymbolManager.symbol_deselected.emit()
	SymbolManager.symbol_edit_ended.emit()

