# Image viewer UI (middle left)
# controles image & symbol display scene

extends PanelContainer
class_name ImageViewer

@export var symbol_scene = preload("res://image_viewer/symbol/symbol_scene.tscn")
@export var image_scene = preload("res://image_viewer/image_scene.tscn")

@onready var image_viewport = $SubViewportContainer/SubViewport
@onready var image_view_camera = $SubViewportContainer/SubViewport/ImageViewCamera
@onready var symbol_selection_filter = $SubViewportContainer/SubViewport/SymbolSelectionFilter
@onready var symbol_editor_scene = $SubViewportContainer/SubViewport/SymbolEditorScene

var project_scene_group_dict = {} 
var active_project_xml_dict = {} # key: xml_stat, value: symbol scene
var is_mouse_on = false


func _ready():
	SymbolManager.symbol_added.connect(_on_add_new_symbol)
	ProjectManager.xml_visibility_changed.connect(_on_xml_visibility_changed)
	

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
		add_child_scenes(scene_group, active_project)
		project_scene_group_dict[active_project] = scene_group
	
	reset_active_project_xml_dict(active_project)
	symbol_selection_filter.set_current(active_project_xml_dict)
	
	
# let only active symbol scene adds new symbol
func _on_add_new_symbol(xml_id:int, symbol_id:int):
	var xml_stat = ProjectManager.get_xml(xml_id)
	active_project_xml_dict[xml_stat].add_new_symbol(xml_id, symbol_id)
		
		
func add_child_scenes(parent: Node2D, active_project: Project):
	var image_scene_instance = image_scene.instantiate() as ImageScene
	var texture_size = image_scene_instance.set_texture(active_project.img)
	image_view_camera.global_position = texture_size/2
	parent.add_child(image_scene_instance)
	for xml_stat in active_project.xml_status:
		var symbol_scene_instance = symbol_scene.instantiate() as SymbolScene
		symbol_scene_instance.populate_symbol_bboxes(xml_stat)
		parent.add_child(symbol_scene_instance)
	
	
func reset_active_project_xml_dict(active_project: Project):
	active_project_xml_dict
	for child_node in project_scene_group_dict[active_project].get_children():
		if child_node is SymbolScene:
			active_project_xml_dict[child_node.xml_stat] = child_node


func _on_xml_visibility_changed(xml_id: int):
	var xml_stat = ProjectManager.get_xml(xml_id)
	active_project_xml_dict[xml_stat].visible = xml_stat.is_visible

	
func _on_mouse_entered():
	is_mouse_on = true


func _on_mouse_exited():
	is_mouse_on = false
