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

var project_scene_group_dict = {} 
var active_project_xml_dict = {} # key: xml_stat, value: symbol scene
var is_mouse_on = false


func _ready():
	image_view_context_menu.context_poped_up.connect(on_context_popup)
	image_view_context_menu.context_add_clicked.connect(on_add_symbol)
	image_view_context_menu.context_remove_clicked.connect(on_remove_symbol)
	

func _input(event):
	if !image_view_context_menu.visible:
		image_view_camera.process_input(event)

	if is_mouse_on:
		symbol_selection_filter.process_input(event)
		image_view_context_menu.process_input(event)


func use_project(active_project: Project) -> void:
	if project_scene_group_dict.has(active_project): # move tab focus
		for project in project_scene_group_dict:
			if project == active_project:
				project_scene_group_dict[project].visible = true
			else:
				project_scene_group_dict[project].visible = false
	else: # new tab add (=open new project)
		var scene_group = Node2D.new() # has image & symbol scenes
		image_viewport.add_child(scene_group)
		add_child_scenes(scene_group, active_project)
		project_scene_group_dict[active_project] = scene_group
	
	reset_active_project_xml_dict(active_project)
	symbol_selection_filter.set_current(active_project_xml_dict)
		
		
func add_child_scenes(parent: Node2D, active_project: Project):
	var image_scene_instance = image_scene.instantiate() as ImageScene
	var texture_size = image_scene_instance.set_texture(active_project.img)
	image_view_camera.global_position = texture_size/2
	parent.add_child(image_scene_instance)
	for xml_stat in active_project.xml_status:
		var symbol_scene_instance = symbol_scene.instantiate() as SymbolScene
		symbol_scene_instance.populate_symbol_bboxes(xml_stat)
		#symbol_scene_instance.set_watched_filter(symbol_selection_filter)
		#symbol_selection_filter.update_watch(symbol_scene_instance)
		parent.add_child(symbol_scene_instance)
	
	
func reset_active_project_xml_dict(active_project: Project):
	active_project_xml_dict
	for child_node in project_scene_group_dict[active_project].get_children():
		if child_node is SymbolScene:
			active_project_xml_dict[child_node.xml_stat] = child_node


func change_visibility(xml_id: int):
	var xml_stat = ProjectManager.get_xml(xml_id)
	active_project_xml_dict[xml_stat].visible = xml_stat.is_visible


func on_context_popup():
	image_view_camera.is_dragging = false 
	
	
func on_add_symbol(pos: Vector2):
	var pos_in_image = image_view_camera.get_pixel_from_image_canvas(pos)
	var new_symbol_id = ProjectManager.active_project.xml_status[0].add_new_symbol(pos_in_image) # TODO: how to set target xml?
	
	SymbolManager.symbol_added.emit(0, new_symbol_id)
	SymbolManager.symbol_selected_from_image.emit(0, new_symbol_id)	
	SymbolManager.symbol_edit_started.emit(0, new_symbol_id)
	SymbolManager.symbol_edited.emit(0, new_symbol_id)
	
	
func on_remove_symbol():
	var xml_id = SymbolManager.selected_xml_id
	var symbol_id = SymbolManager.selected_symbol_id
	ProjectManager.active_project.xml_status[xml_id].remove_symbol(symbol_id)
	
	SymbolManager.symbol_edited.emit(xml_id, symbol_id)
	SymbolManager.symbol_deselected.emit()
	SymbolManager.symbol_edit_ended.emit()
	


func _on_mouse_entered():
	is_mouse_on = true


func _on_mouse_exited():
	is_mouse_on = false
