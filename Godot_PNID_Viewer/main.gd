# --- Main scene
# Controls open, close, change of project

extends Node

@onready var main_menu: Control = $CanvasLayer/MainWindow/MainMenu
@onready var image_viewer: Control = $CanvasLayer/MainWindow/Middle/ImageViewer
@onready var project_info: Control = $CanvasLayer/MainWindow/Middle/ProjectViewer/ProjectInfo
@onready var symbol_tree: Control = $CanvasLayer/MainWindow/Middle/ProjectViewer/SymbolTree


func _ready():
	main_menu.file_opened.connect(on_new_project)
	
	SymbolManager.symbol_edited.connect(on_symbol_edited)


func on_new_project(paths: PackedStringArray) -> void:
	var project: Project = ProjectManager.add_project(paths)
	if project != null: # TODO: fail case dialog
		make_project_active(project)


func make_project_active(project: Project) -> void:
	ProjectManager.make_project_active(project)
	
	image_viewer.use_project(project)
	project_info.use_project(project)
	symbol_tree.use_project(project)
	
	# make menubar adds new tab
	

func on_symbol_edited(xml_id: int, symbol_id: int):
	var target_xml_stat = ProjectManager.active_project.xml_status[xml_id]
	target_xml_stat.dirty = true
	project_info.update_xml_status(target_xml_stat)
	
	var target_symbol = target_xml_stat.symbol_objects[symbol_id]
	symbol_tree.update_symbol(xml_id, target_symbol)

	
