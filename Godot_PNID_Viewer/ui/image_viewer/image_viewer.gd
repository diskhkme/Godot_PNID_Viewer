# Image viewer UI (middle left)
# controles image & xml(list of symbols) display scene

extends PanelContainer
class_name ImageViewer

signal screenshot_taken(img: Image)

const ImageScene = preload("res://ui/image_viewer/image_scene.tscn")
const XMLScene = preload("res://ui/image_viewer/symbol/xml_scene.tscn")
const SymbolSelectionFilter = preload("res://ui/image_viewer/symbol/symbol_selection_filter.tscn")
const SymbolEditorController = preload("res://ui/image_viewer/symbol/editing/symbol_editor_controller.tscn")

@onready var image_export = $ImageExport
@onready var image_viewport = $SubViewportContainer/SubViewport
@onready var image_view_camera = $SubViewportContainer/SubViewport/ImageViewCamera

class NodeRef:
	var project_node: Node2D
	var selection_filter
	var editor_control
	var image_scene
	var xml_nodes = {} # key: xml_data, value: xml scene, for active project

var node_table = {}

var active_selection_filter
var active_editor_control

var is_editing = false
var selected

func _ready():
	pass
	#SignalManager.symbol_selected.connect(_on_symbol_selected)
	#SignalManager.symbol_deselected.connect(_on_symbol_deselected)
	
	#SignalManager.symbol_added.connect(_add_new_symbol_to_xml_scene)
	#SignalManager.xml_visibility_changed.connect(_update_xml_visibility)


func use_project(project: Project):
	if !node_table.has(project): # add new nodes
		var node_ref = NodeRef.new()
		
		node_ref.project_node = Node2D.new() # has image & symbol scenes
		node_ref.project_node.name = project.img_filename
		node_ref.selection_filter = _add_child_selection_filter(node_ref.project_node)
		node_ref.editor_control = _add_child_editor_control(node_ref.project_node)
		node_ref.image_scene = _add_child_image_scene(node_ref.project_node)
		node_ref.image_scene.set_texture(project.img)
		image_view_camera.global_position = Vector2(project.img.get_width()*0.5, project.img.get_height()*0.5) 
		for xml_data in project.xml_datas:
			node_ref.xml_nodes[xml_data] = _add_child_xml_scene(node_ref.project_node, xml_data)
			
		node_ref.selection_filter.set_target_xml_scene(node_ref.xml_nodes.values())
		node_table[project] = node_ref
	
	update_node_tree(project)
	
		
	
func get_camera():
	return image_view_camera
	

func process_input(event):
	image_view_camera.process_input(event)

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
			

func update_node_tree(project):
	for p in node_table:
		if node_table[p].project_node.get_parent() != null:
			image_viewport.remove_child(node_table[p].project_node)
		
	image_viewport.add_child(node_table[project].project_node)
	
	
func close_project(project: Project):
	node_table[project].project_node.free()
	node_table.erase(project)
	
	
func update_xml(project: Project): # ex, xml added
	for xml_data in project.xml_datas:
		if not node_table[project].xml_nodes.has(xml_data):
			_add_child_xml_scene(node_table[project].project_node, xml_data)
	
	
#func _add_new_symbol_to_xml_scene(symbol_object: SymbolObject):
	#active_xml_scene[symbol_object.source_xml].add_child_static_symbol(symbol_object)
		
		
func _add_child_xml_scene(parent: Node2D, xml_data: XMLData):
	var xml_scene_instance = XMLScene.instantiate() as XMLScene
	xml_scene_instance.populate_symbol_bboxes(xml_data)
	xml_scene_instance.name = xml_data.filename
	parent.add_child(xml_scene_instance)
	return xml_scene_instance
	
		
func _add_child_image_scene(parent: Node2D):
	var image_scene_instance = ImageScene.instantiate() as ImageScene
	parent.add_child(image_scene_instance)
	return image_scene_instance
	
	
func _add_child_selection_filter(parent: Node2D):
	var selection_filter = SymbolSelectionFilter.instantiate()
	parent.add_child(selection_filter)
	return selection_filter
	
	
func _add_child_editor_control(parent: Node2D):
	var editor_control = SymbolEditorController.instantiate()
	editor_control.visible = false
	parent.add_child(editor_control)
	return editor_control


#func _update_xml_visibility(xml_data: XMLData):
	#active_xml_scene[xml_data].visible = xml_data.is_visible

func generate_screenshot(path: String):
	var screenshot = await image_export.take_screenshot()
	screenshot_taken.emit(screenshot, path)
	
	
#func _on_symbol_selected(symbol_object):
	#selected = symbol_object
	#active_selection_filter.visible = false
	#active_editor_control.visible = true
	#active_editor_control.initialize(symbol_object)
	#is_editing = true
	#
	#
#func _on_symbol_deselected(symbol_object):
	#active_selection_filter.visible = true
	#active_editor_control.visible = false
	#is_editing = false
	
