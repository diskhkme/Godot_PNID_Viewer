# Image viewer UI (middle left)
# controles image & xml(list of symbols) display scene

extends PanelContainer
class_name ImageViewer

signal symbol_selected(symbol_object: SymbolObject, from_tree: bool)
signal symbol_editing(symbol_object: SymbolObject)
signal symbol_deselected(edited: bool) # true if edited, false if canceled
signal screenshot_taken(img: Image)
signal zoom_changed(zoom: float)
signal camera_moved(pos: Vector2)

const ImageScene = preload("res://ui/image_viewer/image_scene.tscn")
const XMLScene = preload("res://ui/image_viewer/symbol/xml_scene.tscn")
const SymbolSelectionFilter = preload("res://ui/image_viewer/symbol/symbol_selection_filter.tscn")
const SymbolEditorController = preload("res://ui/image_viewer/symbol/editing/symbol_editor_controller.tscn")

@onready var _image_export = $ImageExport
@onready var _image_viewport = $SubViewportContainer/SubViewport
@onready var _image_view_camera = $SubViewportContainer/SubViewport/ImageViewCamera

class NodeRef:
	var project_node: Node2D
	var selection_filter
	var editor_control
	var image_scene
	var xml_nodes = {} # key: xml_data, value: [xml symbol scene, xml text scene], for active project

var _node_table = {}

# just shortcuts about active project
var _active_selection_filter
var _active_editor_control
var _active_xml_nodes

var selected_symbol

func _ready():
	_image_view_camera.zoom_changed.connect(_on_zoom_changed)
	_image_view_camera.moved.connect(_on_camera_moved)
	

func use_project(project: Project):
	if not _node_table.has(project): # add new nodes
		var node_ref = NodeRef.new()
		
		node_ref.project_node = Node2D.new() # has image & symbol scenes
		node_ref.project_node.name = project.img_filename
		node_ref.selection_filter = _add_child_selection_filter(node_ref.project_node)
		node_ref.editor_control = _add_child_editor_control(node_ref.project_node)
		node_ref.image_scene = _add_child_image_scene(node_ref.project_node)
		node_ref.image_scene.set_texture(project.img)
		_image_view_camera.set_cam_position(Vector2(project.img.get_width()*0.5, project.img.get_height()*0.5))
		for xml_data in project.xml_datas:
			node_ref.xml_nodes[xml_data] = _add_child_xml_scene(node_ref.project_node, xml_data)
			
		node_ref.selection_filter.set_target_xml_scene(node_ref.xml_nodes.values())
		_node_table[project] = node_ref
	
	Util.log_start("update_node_tree")
	_update_node_tree(project)
	Util.log_end("update_node_tree")
	_active_selection_filter = _node_table[project].selection_filter
	_active_editor_control = _node_table[project].editor_control
	_active_xml_nodes = _node_table[project].xml_nodes
	
		
func get_camera():
	return _image_view_camera
	
	
func cancel_selected(): # force hiding when symbol is removed
	_process_symbol_deselected()
	
	
func select_symbol(symbol_object: SymbolObject):
	if selected_symbol != symbol_object:
		_process_symbol_deselected()
	_process_symbol_selected(symbol_object)
	_image_view_camera.focus_symbol(symbol_object)


func process_input(event):
	_image_view_camera.process_input(event)

	if _active_editor_control.visible:
		if !_active_editor_control.process_input(event): #end editing
			if _active_editor_control.is_actually_edited:
				symbol_deselected.emit(selected_symbol, true)
			else:
				symbol_deselected.emit(selected_symbol, false)
			_process_symbol_deselected()
		else:
			symbol_editing.emit(selected_symbol)
	else:
		var selected = _active_selection_filter.process_input(event) 
		_active_xml_nodes.values().map(func(s): s.process_input(event))
		if selected != null:
			symbol_selected.emit(selected, false)
			_process_symbol_selected(selected)

			
func _process_symbol_selected(selected):
	_active_editor_control.initialize(selected)
	_active_editor_control.visible = true
	_active_xml_nodes[selected.source_xml].hide_symbol_node(selected)
	_active_selection_filter.clear_candidates()
	_image_view_camera.focus_symbol(selected)
	selected_symbol = selected
	
	
func _process_symbol_deselected():
	if selected_symbol == null:
		return
	_active_editor_control.visible = false
	_active_xml_nodes[selected_symbol.source_xml].show_symbol_node(selected_symbol)
	_active_selection_filter.clear_candidates()
	selected_symbol = null
			

func _update_node_tree(project):
	for p in _node_table:
		if _node_table[p].project_node.get_parent() != null:
			_image_viewport.remove_child(_node_table[p].project_node)
		
	Util.log_start("add_project_node")
	_image_viewport.add_child(_node_table[project].project_node)
	Util.log_end("add_project_node")
	
	Util.log_start("update_xml")
	update_xml(project)
	Util.log_end("update_xml")
	
	
func close_project(project: Project):
	_node_table[project].project_node.free()
	_node_table.erase(project)
	
	
func update_xml(project: Project): # ex, xml added
	# TODO: consider xml clsed case (and add xml close interface)
	for xml_data in project.xml_datas:
		if not _node_table[project].xml_nodes.has(xml_data):
			Util.log_start("child_scene %s" % xml_data.filename)
			var new_xml_node = _add_child_xml_scene(_node_table[project].project_node, xml_data)
			Util.log_end("child_scene %s" % xml_data.filename)
			_node_table[project].xml_nodes[xml_data] = new_xml_node
			
	_node_table[project].selection_filter.set_target_xml_scene(_node_table[project].xml_nodes.values())
	
		
func _add_child_xml_scene(parent: Node2D, xml_data: XMLData):
	var xml_scene_instance = XMLScene.instantiate() as XMLScene
	xml_scene_instance.populate_symbol_bboxes(xml_data)
	xml_scene_instance.name = xml_data.filename
	Util.log_start("child_scene add tree %s" % xml_data.filename)
	parent.add_child(xml_scene_instance)
	Util.log_end("child_scene add tree %s" % xml_data.filename)
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
	
	
func apply_symbol_change(symbol_object: SymbolObject):
	var xml_scene = _active_xml_nodes[symbol_object.source_xml]
	if xml_scene.has_symbol(symbol_object): 
		if symbol_object.source_xml.symbol_objects.has(symbol_object): # symbol edited
			xml_scene.apply_symbol_edit(symbol_object)
		else: # symbol add undo
			xml_scene.remove_symbol_node(symbol_object)
	else: # symbol added
		xml_scene.add_symbol_node(symbol_object)
	
	
func update_xml_visibility(xml_data: XMLData):
	_node_table[ProjectManager.active_project].xml_nodes[xml_data].update_visibility()
	
	
func update_label_visibility(xml_data: XMLData):
	_node_table[ProjectManager.active_project].xml_nodes[xml_data].set_label_visibility(xml_data.is_show_label)
	

func generate_screenshot(path: String):
	var screenshot = await _image_export.take_screenshot()
	screenshot_taken.emit(screenshot, path)
	
	
func _on_zoom_changed(zoom: float):
	zoom_changed.emit(zoom)
	
	
func _on_camera_moved(pos: Vector2):
	camera_moved.emit(pos)
