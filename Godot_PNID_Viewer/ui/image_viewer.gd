extends PanelContainer
class_name ImageViewer

@onready var image_scene = $SubViewportContainer/SubViewport/ImageScene
@onready var symbol_scene = $SubViewportContainer/SubViewport/SymbolScene
@onready var image_viewport = $SubViewportContainer/SubViewport
@onready var camera = $SubViewportContainer/SubViewport/Camera2D


func use_project(project: Project) -> void:
	var texture_size = image_scene.load_image_as_texture(project.img_filepath)
	# TODO: 다른 프로젝트에서 생성한 것들을 대체할 것인지, 씬을 계속 추가할 것인지 결정 필요
	symbol_scene.populate_symbol_bboxes(project.xml_status) 
	
	adjust_viewport_to_fullscreen()
	move_cam_to(texture_size/2)
	
	SymbolManager.symbol_selected_from_tree.connect(focus_img)
	
	
func adjust_viewport_to_fullscreen():
	var window_size = DisplayServer.window_get_size()
	image_viewport.size = window_size
	print(window_size)
	

func move_cam_to(pos: Vector2) -> void:
	camera.global_position = pos
	

func focus_img(xml_id:int, symbol_id:int) -> void:
	var target_sym = ProjectManager.active_project.xml_status[xml_id].symbol_objects[symbol_id]
	var target_pos = Vector2((target_sym.bndbox.x + target_sym.bndbox.z)/2, 
							(target_sym.bndbox.y + target_sym.bndbox.w)/2)
	move_cam_to(target_pos)
	
