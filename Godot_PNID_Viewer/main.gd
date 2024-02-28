# --- Main scene
# Controls open, close, change of project

extends Node

@onready var main_menu: Control = $CanvasLayer/MainWindow/MainMenu
@onready var image_viewer: Control = $CanvasLayer/MainWindow/Middle/ImageViewer
@onready var project_info: Control = $CanvasLayer/MainWindow/Middle/ProjectViewer/ProjectInfo
@onready var symbol_info: Control = $CanvasLayer/MainWindow/Middle/ProjectViewer/SymbolInfo


func _ready():
	main_menu.file_opened.connect(on_new_project)


func on_new_project(paths: PackedStringArray) -> void:
	var project: Project = ProjectManager.add_project(paths)
	if project != null: # TODO: fail case dialog
		make_project_active(project)


func make_project_active(project: Project) -> void:
	ProjectManager.make_project_active(project)
	
	image_viewer.use_project(project)
	project_info.use_project(project)
	symbol_info.use_project(project)
	
	# make menubar adds new tab
	

	
