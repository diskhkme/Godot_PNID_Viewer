# Image viewer UI (middle left)
# controles image & xml(list of symbols) display scene

extends PanelContainer
class_name ImageViewer

@export var xml_scene = preload("res://image_viewer/symbol/xml_scene.tscn")
@export var image_scene = preload("res://image_viewer/image_scene.tscn")

@onready var image_viewport = $SubViewportContainer/SubViewport
@onready var image_view_camera = $SubViewportContainer/SubViewport/ImageViewCamera
@onready var symbol_selection_filter = $SubViewportContainer/SubViewport/SymbolSelectionFilter
@onready var symbol_editor_scene = $SubViewportContainer/SubViewport/SymbolEditorScene

var project_scene_group_dict = {} 
var active_project_xml_dict = {} # key: xml_data, value: symbol scene
var is_mouse_on = false


func _ready():
	SignalManager.symbol_added.connect(_add_new_symbol_to_xml_scene)
	SignalManager.xml_visibility_changed.connect(_update_xml_visibility)
	SignalManager.xml_added.connect(_add_xml_scene)
	

func process_input(event):
	image_view_camera.process_input(event)

	if is_mouse_on:
		symbol_selection_filter.process_input(event)


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
		add_child_image_scene(scene_group, active_project)
		for xml_data in active_project.xml_datas:
			add_child_xml_scene(scene_group, xml_data)
		project_scene_group_dict[active_project] = scene_group
	
	reset_active_project_xml_dict(active_project)
	symbol_selection_filter.set_current(active_project_xml_dict)
	
	
func _add_xml_scene(xml_data: XMLData):
	var scene_group = project_scene_group_dict[ProjectManager.active_project]
	add_child_xml_scene(scene_group, xml_data)

	
# let only active symbol scene adds new symbol
func _add_new_symbol_to_xml_scene(xml_id:int, symbol_id:int):
	var xml_data = ProjectManager.get_xml(xml_id)
	active_project_xml_dict[xml_data].add_new_symbol(xml_id, symbol_id)
		
		
func add_child_xml_scene(parent: Node2D, xml_data: XMLData):
	var xml_scene_instance = xml_scene.instantiate() as SymbolScene
	xml_scene_instance.populate_symbol_bboxes(xml_data)
	parent.add_child(xml_scene_instance)
	
		
func add_child_image_scene(parent: Node2D, active_project: Project):
	var image_scene_instance = image_scene.instantiate() as ImageScene
	var texture_size = image_scene_instance.set_texture(active_project.img)
	image_view_camera.global_position = texture_size/2
	parent.add_child(image_scene_instance)
	
	
func reset_active_project_xml_dict(active_project: Project):
	for child_node in project_scene_group_dict[active_project].get_children():
		if child_node is SymbolScene:
			active_project_xml_dict[child_node.xml_data] = child_node


func _update_xml_visibility(xml_data: XMLData):
	active_project_xml_dict[xml_data].visible = xml_data.is_visible

	
func _on_mouse_entered():
	is_mouse_on = true


func _on_mouse_exited():
	is_mouse_on = false
