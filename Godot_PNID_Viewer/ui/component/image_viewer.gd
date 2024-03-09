# Image viewer UI (middle left)
# controles image & symbol display scene

extends PanelContainer
class_name ImageViewer

@export var symbol_scene = preload("res://image_viewer/symbol/symbol_scene.tscn")
@export var image_scene = preload("res://image_viewer/image_scene.tscn")

@onready var image_viewport = $SubViewportContainer/SubViewport
@onready var image_view_camera = $SubViewportContainer/SubViewport/ImageViewCamera
@onready var symbol_selection_filter = $SubViewportContainer/SubViewport/SymbolSelectionFilter
@onready var image_view_context_menu = %ImageViewContextMenu

var xml_stat_scene_dict = {}
var project_symbol_scenes_dict = {}
var project_image_scene_dict = {}
var is_mouse_on = false


func _ready():
	image_view_context_menu.context_poped_up.connect(on_context_popup)
	image_view_context_menu.context_add_clicked.connect(on_add_symbol)
	image_view_context_menu.context_remove_clicked.connect(on_remove_symbol)
	

func _input(event):
	if !image_view_context_menu.visible:
		image_view_camera.process_input(event)

	symbol_selection_filter.process_input(event)
	image_view_context_menu.process_input(event)


func use_project(target_project: Project) -> void:
	if project_image_scene_dict.has(target_project): # move tab focus
		for project in project_image_scene_dict:
			if project == target_project:
				for scene in project_symbol_scenes_dict[project]:
					scene.visible = true
				project_image_scene_dict[project].visible = true
			else:
				for scene in project_symbol_scenes_dict[project]:
					scene.visible = false
				project_image_scene_dict[project].visible = false
	else: # new tab add
		var image_scene_instance = image_scene.instantiate() as ImageScene
		image_viewport.add_child(image_scene_instance)
		var texture_size = image_scene_instance.load_image_as_texture(target_project.img_filepath)
		project_image_scene_dict[target_project] = image_scene_instance
		project_symbol_scenes_dict[target_project] = []
		for xml_stat in target_project.xml_status:
			var symbol_scene_instance = symbol_scene.instantiate() as SymbolScene
			symbol_scene_instance.populate_symbol_bboxes(xml_stat)
			symbol_scene_instance.set_watched_filter(symbol_selection_filter)
			symbol_selection_filter.set_watch(symbol_scene_instance)
			image_viewport.add_child(symbol_scene_instance)
			xml_stat_scene_dict[xml_stat] = symbol_scene_instance
	
			project_symbol_scenes_dict[target_project].push_back(symbol_scene_instance)
	
		adjust_viewport_to_fullscreen()
		image_view_camera.global_position = texture_size/2
	

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
	
	
func on_context_popup():
	image_view_camera.is_dragging = false 
	
	
func on_add_symbol(pos: Vector2):
	var pos_in_image = image_view_camera.get_pixel_from_image_canvas(pos)
	var new_symbol_id = ProjectManager.active_project.xml_status[0].add_new_symbol(pos_in_image) # TODO: how to set target xml?
	
	SymbolManager.symbol_added.emit(0, new_symbol_id)
	SymbolManager.symbol_selected_from_image.emit(0, new_symbol_id)	
	SymbolManager.symbol_edit_started.emit(0, new_symbol_id)
	
	
func on_remove_symbol():
	var xml_id = SymbolManager.selected_xml_id
	var symbol_id = SymbolManager.selected_symbol_id
	ProjectManager.active_project.xml_status[xml_id].remove_symbol(symbol_id)
	
	SymbolManager.symbol_edited.emit(xml_id, symbol_id)
	SymbolManager.symbol_deselected.emit()
	SymbolManager.symbol_edit_ended.emit()
	
