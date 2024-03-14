# XML Tree Viewer
# Display symbol information of the middle right table-like GUI

extends Control

signal request_type_change_window

@onready var tree = $Tree

var xml_item_arr = []
var symbol_items_dict = [] # arr of dict [xml_id]{key: symbol_id, val: symbol_item}
var symbol_update_cache = {}
var root
var is_mouse_on = false

const COLUMN_COUNT = 8

func _ready():
	reset_tree()
	SymbolManager.symbol_selected_from_image.connect(_select_symbol)
	SymbolManager.symbol_deselected.connect(_deselect_symbol)
	SymbolManager.symbol_edited.connect(_edit_symbol)
	SymbolManager.symbol_added.connect(_add_symbol)
	
	ProjectManager.xml_visibility_changed.connect(_change_visibility)
	ProjectManager.xml_selectability_changed.connect(_change_selectability)

#-------------------------------------------------------------
# Tree Initialization-----------------------------------------
#-------------------------------------------------------------
func use_project(project: Project):
	reset_tree()
	symbol_items_dict.clear()
	xml_item_arr.clear()

	for xml_stat in project.xml_status:
		var xml_item = add_xml_on_tree(xml_stat)
		symbol_items_dict.push_back({})
		for symbol_object in xml_stat.symbol_objects:
			var symbol_item = add_symbol_on_tree(xml_item, symbol_object)
			symbol_items_dict[xml_stat.id][symbol_object.id] = symbol_item
			symbol_item.set_custom_color(0, symbol_object.color)
		
		_change_visibility(xml_stat.id)
		_change_selectability(xml_stat.id)	


func reset_tree():
	tree.clear()
	tree.set_columns(COLUMN_COUNT)
	tree.set_column_title(0, "ID")
	tree.set_column_clip_content(0, true)
	tree.set_column_custom_minimum_width(0, 100)
	tree.set_column_title(1, "Type")
	tree.set_column_clip_content(1, true)
	tree.set_column_custom_minimum_width(1, 100)
	tree.set_column_title(2, "Class")
	tree.set_column_clip_content(2, true)
	tree.set_column_custom_minimum_width(2, 100)
	tree.set_column_title(3, "XMin")
	tree.set_column_title(4, "YMin")
	tree.set_column_title(5, "XMax")
	tree.set_column_title(6, "YMax")
	tree.set_column_title(7, "Deg")
	tree.column_titles_visible = true
	
	for i in range(COLUMN_COUNT):
		if i != 2:
			tree.set_column_expand(i, false)
			
	root = tree.create_item() 
	tree.hide_root = true


func add_xml_on_tree(xml_stat: XML_Status) -> TreeItem:
	var xml_item = tree.create_item(root)
	xml_item.set_text(0,xml_stat.filename)
	for i in range(COLUMN_COUNT):
		xml_item.set_selectable(i, false)
		
	xml_item_arr.push_back(xml_item)		
	return xml_item
	
	
func add_symbol_on_tree(parent: TreeItem, symbol_object: SymbolObject) -> TreeItem:
	var symbol_item: TreeItem = tree.create_item(parent)
	fill_treeitem(symbol_item,symbol_object)
	if symbol_object.is_text:
		# TODO: text editing does not signal symbol edited
		symbol_item.set_editable(2, true)
		
	return symbol_item
	
	
func fill_treeitem(symbol_child: TreeItem, symbol_object: SymbolObject):
	symbol_child.set_text(0, str(symbol_object.id))
	symbol_child.set_text(1, symbol_object.type)
	symbol_child.set_text(2, symbol_object.cls)
	symbol_child.set_text(3, str(floor(symbol_object.bndbox.x)))
	symbol_child.set_text(4, str(floor(symbol_object.bndbox.y)))
	symbol_child.set_text(5, str(floor(symbol_object.bndbox.z)))
	symbol_child.set_text(6, str(floor(symbol_object.bndbox.w)))
	symbol_child.set_text(7, str(symbol_object.degree))
	
	if symbol_object.removed:
		symbol_child.visible = false
		
#-------------------------------------------------------------
# Self Event Handle  -----------------------------------------
#-------------------------------------------------------------
func _on_tree_item_selected():
	var selected_symbol_id = tree.get_selected().get_text(0).to_int()
	var selected_xml_filename = tree.get_selected().get_parent().get_text(0)
	var selected_xml_id = ProjectManager.active_project.get_xml_id_from_filename(selected_xml_filename)
	if selected_xml_id != -1 && selected_symbol_id != -1:
		SymbolManager.symbol_selected_from_tree.emit(selected_xml_id,selected_symbol_id)
		SymbolManager.symbol_edit_started.emit(selected_xml_id,selected_symbol_id)
	

func _input(event):
	# limit area to treeviewer
	if !is_mouse_on:
		return
				
	# bring type class editing window by double clicking
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.double_click: 
			var selected_symbol_id = tree.get_selected().get_text(0).to_int()
			var selected_xml_filename = tree.get_selected().get_parent().get_text(0)
			var selected_xml_id = ProjectManager.active_project.get_xml_id_from_filename(selected_xml_filename)
			var xml_stat = ProjectManager.get_xml(selected_xml_id)
			var symbol_object = ProjectManager.get_symbol_in_xml(selected_xml_id, selected_symbol_id)
			request_type_change_window.emit(xml_stat, symbol_object)
			
			
func _on_tree_column_title_clicked(column, mouse_button_index):
	if mouse_button_index == MOUSE_BUTTON_LEFT:
		for xml_id in range(xml_item_arr.size()):
			var xml_stat = ProjectManager.get_xml(xml_id)
			var xml_item = xml_item_arr[xml_id]
			# sort symbol object itself
			var symbol_objects = xml_stat.symbol_objects
			symbol_objects.sort_custom(sort_function(column))
			var symbol_items = xml_item.get_children()
			for i in range(symbol_objects.size()):
				fill_treeitem(symbol_items[i], symbol_objects[i])
				symbol_items_dict[xml_id][symbol_objects[i].id] = symbol_items[i]


func sort_function(column):
	match column:
		0: return func(a,b): return a.id < b.id
		1: return func(a,b): return a.type.naturalnocasecmp_to(b.type) < 0
		2: return func(a,b): return a.cls.naturalnocasecmp_to(b.cls) < 0
		3: return func(a,b): return a.bndbox.x < b.bndbox.x
		4: return func(a,b): return a.bndbox.y < b.bndbox.y
		5: return func(a,b): return a.bndbox.z < b.bndbox.z
		6: return func(a,b): return a.bndbox.w < b.bndbox.w
		7: return func(a,b): return a.degree < b.degree
			

func _on_mouse_entered():
	is_mouse_on = true


func _on_mouse_exited():
	is_mouse_on = false

			
#-------------------------------------------------------------
# Received Evnet Handle---------------------------------------
#-------------------------------------------------------------			
func _select_symbol(xml_id:int, symbol_id:int):
	var symbol_item = symbol_items_dict[xml_id][symbol_id]
	symbol_item.select(0)
	tree.scroll_to_item(symbol_item)
	
	
func _deselect_symbol():
	tree.deselect_all()

	
func _add_symbol(xml_id:int, symbol_id: int):
	var xml_tree = xml_item_arr[xml_id]
	var symbol_object = ProjectManager.get_symbol_in_xml(xml_id, symbol_id)
	var symbol_item = add_symbol_on_tree(xml_tree, symbol_object)
	symbol_items_dict[xml_id][symbol_id] = symbol_item
	symbol_update_cache[symbol_object] = symbol_item


func _edit_symbol(xml_id: int, symbol_id: int):
	var symbol_object = ProjectManager.get_symbol_in_xml(xml_id, symbol_id)
	var symbol_item = symbol_items_dict[xml_id][symbol_id]
	fill_treeitem(symbol_item, symbol_object)
	symbol_update_cache[symbol_object] = symbol_item


func _change_visibility(xml_id: int):
	var xml_stat = ProjectManager.get_xml(xml_id)
	xml_item_arr[xml_id].visible = xml_stat.is_visible
			
			
func _change_selectability(xml_id: int):
	var xml_stat = ProjectManager.get_xml(xml_id)
	for symbol_item in symbol_items_dict[xml_id].values():
		for i in range(COLUMN_COUNT):
			symbol_item.set_selectable(i,xml_stat.is_selectable)

