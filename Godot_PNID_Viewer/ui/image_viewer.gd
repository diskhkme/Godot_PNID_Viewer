# Image viewer UI (middle left)
# controles image & symbol display scene

extends PanelContainer
class_name ImageViewer

@onready var image_scene = $SubViewportContainer/SubViewport/ImageScene
@onready var image_viewport = $SubViewportContainer/SubViewport
@onready var camera = $SubViewportContainer/SubViewport/Camera2D
@onready var symbol_scene = $SubViewportContainer/SubViewport/SymbolScene


func use_project(project: Project) -> void:
	var texture_size = image_scene.load_image_as_texture(project.img_filepath)
	# TODO: 다른 프로젝트에서 생성한 것들을 대체할 것인지, 씬을 계속 추가할 것인지 결정 필요
	# TODO: generate symbol scene per xml?
	symbol_scene.populate_symbol_bboxes(project.xml_status) 
	
	adjust_viewport_to_fullscreen()
	camera.global_position = texture_size/2
	

func adjust_viewport_to_fullscreen() -> void:
	var window_size = DisplayServer.window_get_size()
	image_viewport.size = window_size
	print(window_size)
	
	

