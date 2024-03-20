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

var symbol_selection_filter
var symbol_editor_control

var project_scene_group_dict = {} 
var active_project_xml_dict = {} # key: xml_data, value: symbol scene
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
			if symbol_editor_control.is_actually_edited:
				SignalManager.symbol_edited.emit(selected)
				
			if !symbol_editor_control.process_input(event): #end editing
				SignalManager.symbol_deselected.emit(selected)
				selected = null
		else:
			var selected = symbol_selection_filter.process_input(event) 
			if selected != null:
				SignalManager.symbol_selected_from_image.emit(selected)
			

func update_activate(active_project):
	for project in project_scene_group_dict:
			if project == active_project:
				project_scene_group_dict[project].visible = true
			else:
				project_scene_group_dict[project].visible = false
				

func use_project(active_project: Project) -> void:
	if !project_scene_group_dict.has(active_project): # add new nodes
		var scene_group = Node2D.new() # has image & symbol scenes
		image_viewport.add_child(scene_group)
		add_child_image_scene(scene_group, active_project)
		for xml_data in active_project.xml_datas:
			add_child_xml_scene(scene_group, xml_data)
		project_scene_group_dict[active_project] = scene_group
	
		add_child_selection_filter_scene(scene_group)
		add_child_editor_control(scene_group)
		
	update_activate(active_project)
	reset_active_project_xml_dict(active_project)
	symbol_selection_filter.set_current(active_project_xml_dict)
	
	
func _add_xml_scene(xml_data: XMLData):
	var scene_group = project_scene_group_dict[ProjectManager.active_project]
	add_child_xml_scene(scene_group, xml_data)

	
func _add_new_symbol_to_xml_scene(symbol_object: SymbolObject):
	active_project_xml_dict[symbol_object.source_xml].add_child_static_symbol(symbol_object)
		
		
func add_child_xml_scene(parent: Node2D, xml_data: XMLData):
	var xml_scene_instance = XMLScene.instantiate() as SymbolScene
	xml_scene_instance.populate_symbol_bboxes(xml_data)
	parent.add_child(xml_scene_instance)
	
		
func add_child_image_scene(parent: Node2D, active_project: Project):
	var image_scene_instance = ImageScene.instantiate() as ImageScene
	var texture_size = image_scene_instance.set_texture(active_project.img)
	image_view_camera.global_position = texture_size/2
	parent.add_child(image_scene_instance)
	
	
func add_child_selection_filter_scene(parent: Node2D):
	symbol_selection_filter = SymbolSelectionFilter.instantiate()
	parent.add_child(symbol_selection_filter)
	
	
func add_child_editor_control(parent: Node2D):
	symbol_editor_control = SymbolEditorController.instantiate()
	parent.add_child(symbol_editor_control)
	
	
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
	
	
func _on_screenshot_requested():
	var screenshot = await image_export.take_screenshot()
	SignalManager.screenshot_taken.emit(screenshot)
	
	
func _on_symbol_selected(symbol_object):
	selected = symbol_object
	symbol_selection_filter.visible = false
	symbol_editor_control.visible = true
	symbol_editor_control.initialize(symbol_object)
	is_editing = true
	
	
func _on_symbol_deselected(symbol_object):
	symbol_selection_filter.visible = true
	symbol_editor_control.visible = false
	is_editing = false
	
