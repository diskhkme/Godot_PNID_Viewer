# Image viewer UI (middle left)
# controles image & symbol display scene

extends PanelContainer
class_name ImageViewer

@export var symbol_scene = preload("res://scene/symbol_scene/symbol_scene.tscn")

@onready var image_scene = $SubViewportContainer/SubViewport/ImageScene
@onready var image_viewport = $SubViewportContainer/SubViewport
@onready var camera = $SubViewportContainer/SubViewport/Camera2D
@onready var symbol_selection_filter = $SubViewportContainer/SubViewport/SymbolSelectionFilter


func use_project(project: Project) -> void:
	var texture_size = image_scene.load_image_as_texture(project.img_filepath)
	# TODO: 다른 프로젝트에서 생성한 것들을 대체할 것인지, 씬을 계속 추가할 것인지 결정 필요
	# TODO: generate symbol scene per xml?
	for xml_stat in project.xml_status:
		var symbol_scene_instance = symbol_scene.instantiate() as SymbolScene
		symbol_scene_instance.populate_symbol_bboxes(xml_stat)
		symbol_scene_instance.set_watched_filter(symbol_selection_filter)
		symbol_selection_filter.add_watch(symbol_scene_instance)
		
		image_viewport.add_child(symbol_scene_instance)
	
	
	adjust_viewport_to_fullscreen()
	camera.global_position = texture_size/2
	

func adjust_viewport_to_fullscreen() -> void:
	var window_size = DisplayServer.window_get_size()
	image_viewport.size = window_size
	print(window_size)
	
	

