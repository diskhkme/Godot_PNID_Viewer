# Image viewer UI (middle left)
# controles image & xml(list of symbols) display scene

extends PanelContainer
class_name ImageViewer

const ImageScene = preload("res://ui/image_viewer/image_scene.tscn")
const XMLScene = preload("res://ui/image_viewer/symbol/xml_scene.tscn")
const SymbolSelectionFilter = preload("res://ui/image_viewer/symbol/symbol_selection_filter.tscn")
const SymbolEditorController = preload("res://ui/image_viewer/symbol/editing/symbol_editor_controller.tscn")

@onready var image_export = $ImageExport
@onready var image_viewport = $SubViewportContainer/SubViewport
@onready var image_view_camera = $SubViewportContainer/SubViewport/ImageViewCamera

var project_scene_group_dict = {} 

var active_selection_filter
var active_editor_control
var active_xml_scene = {} # key: xml_data, value: xml scene
var is_mouse_on = false
var is_editing = false
var selected

func _ready():
	SignalManager.symbol_selected.connect(_on_symbol_selected)
	SignalManager.symbol_deselected.connect(_on_symbol_deselected)
	
	SignalManager.symbol_added.connect(_add_new_symbol_to_xml_scene)
	SignalManager.xml_visibility_changed.connect(_update_xml_visibility)
	SignalManager.xml_added.connect(_add_xml_scene)
	SignalManager.screenshot_requested.connect(_on_screenshot_requested)
	

func process_input(event):
	image_view_camera.process_input(event)

	if is_mouse_on:
		if is_editing:
			if active_editor_control.is_actually_edited:
				SignalManager.symbol_edited.emit(selected)
				
			if !active_editor_control.process_input(event): #end editing
				SignalManager.symbol_deselected.emit(selected)
				selected = null
		else:
			var selected = active_selection_filter.process_input(event) 
			if selected != null:
				SignalManager.symbol_selected_from_image.emit(selected)
			

func update_active_nodes(active_project):
	active_xml_scene.clear()
	
	for project in project_scene_group_dict:
		if project_scene_group_dict[project].get_parent() != null:
			image_viewport.remove_child(project_scene_group_dict[project])
		
	image_viewport.add_child(project_scene_group_dict[active_project])
		
	var nodes = project_scene_group_dict[active_project].get_children()
	for node in nodes:
		if node is SymbolSelectionFilter:
			active_selection_filter = node
		if node is SymbolEditorController:
			active_editor_control = node
		if node is XMLScene:
			active_xml_scene[node.xml_data] = node
			
	active_selection_filter.set_current(active_xml_scene)
	

func use_project(active_project: Project) -> void:
	if !project_scene_group_dict.has(active_project): # add new nodes
		var scene_group = Node2D.new() # has image & symbol scenes
		add_child_selection_filter_scene(scene_group)
		add_child_editor_control(scene_group)
		add_child_image_scene(scene_group, active_project)
		for xml_data in active_project.xml_datas:
			add_child_xml_scene(scene_group, xml_data)
		project_scene_group_dict[active_project] = scene_group
	
	update_active_nodes(active_project)
	
	
	
func _add_xml_scene(xml_data: XMLData):
	var scene_group = project_scene_group_dict[ProjectManager.active_project]
	add_child_xml_scene(scene_group, xml_data)

	
func _add_new_symbol_to_xml_scene(symbol_object: SymbolObject):
	active_xml_scene[symbol_object.source_xml].add_child_static_symbol(symbol_object)
		
		
func add_child_xml_scene(parent: Node2D, xml_data: XMLData):
	var xml_scene_instance = XMLScene.instantiate() as XMLScene
	xml_scene_instance.populate_symbol_bboxes(xml_data)
	parent.add_child(xml_scene_instance)
	active_xml_scene[xml_data] = xml_scene_instance
	
		
func add_child_image_scene(parent: Node2D, active_project: Project):
	var image_scene_instance = ImageScene.instantiate() as ImageScene
	var texture_size = image_scene_instance.set_texture(active_project.img)
	image_view_camera.global_position = texture_size/2
	parent.add_child(image_scene_instance)
	
	
func add_child_selection_filter_scene(parent: Node2D):
	active_selection_filter = SymbolSelectionFilter.instantiate()
	parent.add_child(active_selection_filter)
	
	
func add_child_editor_control(parent: Node2D):
	active_editor_control = SymbolEditorController.instantiate()
	parent.add_child(active_editor_control)


func _update_xml_visibility(xml_data: XMLData):
	active_xml_scene[xml_data].visible = xml_data.is_visible

	
func _on_mouse_entered():
	is_mouse_on = true


func _on_mouse_exited():
	is_mouse_on = false
	
	
func _on_screenshot_requested():
	var screenshot = await image_export.take_screenshot()
	SignalManager.screenshot_taken.emit(screenshot)
	
	
func _on_symbol_selected(symbol_object):
	selected = symbol_object
	active_selection_filter.visible = false
	active_editor_control.visible = true
	active_editor_control.initialize(symbol_object)
	is_editing = true
	
	
func _on_symbol_deselected(symbol_object):
	active_selection_filter.visible = true
	active_editor_control.visible = false
	is_editing = false
	
