# Image viewer UI (middle left)
# controles image & symbol display scene

extends PanelContainer
class_name ImageViewer

@export var symbol_scene = preload("res://image_viewer/symbol/symbol_scene.tscn")

@onready var image_scene = $SubViewportContainer/SubViewport/ImageScene
@onready var image_viewport = $SubViewportContainer/SubViewport
@onready var camera = $SubViewportContainer/SubViewport/ImageViewCamera
@onready var symbol_selection_filter = $SubViewportContainer/SubViewport/SymbolSelectionFilter

var xml_stat_scene_dict = {}

func use_project(project: Project) -> void:
	var texture_size = image_scene.load_image_as_texture(project.img_filepath)
	for xml_stat in project.xml_status:
		var symbol_scene_instance = symbol_scene.instantiate() as SymbolScene
		symbol_scene_instance.populate_symbol_bboxes(xml_stat)
		symbol_scene_instance.set_watched_filter(symbol_selection_filter)
		symbol_selection_filter.set_watch(symbol_scene_instance)
		
		image_viewport.add_child(symbol_scene_instance)
		
		xml_stat_scene_dict[xml_stat] = symbol_scene_instance
	
	
	adjust_viewport_to_fullscreen()
	camera.global_position = texture_size/2
	

func adjust_viewport_to_fullscreen() -> void:
	image_viewport.size = self.size


func change_visibility(xml_id: int):
	for xml_stat in xml_stat_scene_dict:
		if xml_stat.id == xml_id:
			xml_stat_scene_dict[xml_stat].visible = xml_stat.is_visible


func change_selectability(xml_id: int):
	for xml_stat in xml_stat_scene_dict:
		if xml_stat.id == xml_id:
			symbol_selection_filter.set_watch(xml_stat_scene_dict[xml_stat])
