# XML Tree Viewer
# Display symbol information of the middle right table-like GUI

extends Control

signal request_type_change_window(symbol_object: SymbolObject)

@onready var tree = $Tree

var xml_items_dict = {} # xml_data : tree_item
var symbol_items_dict = {} # symbol_object: tree_item
var root
var is_mouse_on = false
var selected_from_tree: bool = false

const COLUMN_COUNT = 8

func _ready():
	reset_tree()
	SignalManager.symbol_selected_from_image.connect(_select_symbol)
	SignalManager.symbol_deselected.connect(_deselect_symbol)
	SignalManager.symbol_edited.connect(_edit_symbol)
	SignalManager.symbol_added.connect(_add_symbol)
	SignalManager.symbol_removed.connect(_remove_symbol)
	
	SignalManager.xml_visibility_changed.connect(_change_visibility)
	SignalManager.xml_selectability_changed.connect(_change_selectability)

#-------------------------------------------------------------
# Tree Initialization-----------------------------------------
#-------------------------------------------------------------
func use_project(project: Project):
	reset_tree()
	symbol_items_dict.clear()
	xml_items_dict.clear()

	for xml_data in project.xml_datas:
		var xml_item = add_xml_on_tree(xml_data)
		for symbol_object in xml_data.symbol_objects:
			var symbol_item = add_symbol_on_tree(xml_item, symbol_object)
			symbol_items_dict[symbol_object] = symbol_item
		
		_change_visibility(xml_data)
		_change_selectability(xml_data)	


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


func add_xml_on_tree(xml_data: XMLData) -> TreeItem:
	var xml_item = tree.create_item(root)
	xml_item.set_text(0,xml_data.filename)
	for i in range(COLUMN_COUNT):
		xml_item.set_selectable(i, false)
		
	xml_items_dict[xml_data] = xml_item		
	return xml_item
	
	
func add_symbol_on_tree(parent: TreeItem, symbol_object: SymbolObject) -> TreeItem:
	var symbol_item: TreeItem = tree.create_item(parent)
	fill_treeitem(symbol_item,symbol_object)
	symbol_item.set_custom_color(0, symbol_object.color)
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
	var selected_item = tree.get_selected()
	var selected_symbol = symbol_items_dict.keys().filter(func(a): return symbol_items_dict[a] == selected_item)
	SignalManager.symbol_selected_from_tree.emit(selected_symbol[0])
	

func _input(event):
	# limit area to treeviewer
	if !is_mouse_on:
		return
				
	# bring type class editing window by double clicking
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.double_click: 
			var selected_symbol = symbol_items_dict.values().filter(func(a): return a == tree.get_selected())
			request_type_change_window.emit(selected_symbol)
			
			
func _on_tree_column_title_clicked(column, mouse_button_index):
	if mouse_button_index == MOUSE_BUTTON_LEFT:
		for prev_symbol_item in symbol_items_dict.values():
			prev_symbol_item.free()
		
		for xml_data in xml_items_dict.keys():
			var symbol_objects = xml_data.symbol_objects
			symbol_objects.sort_custom(sort_function(column))
			var xml_item = xml_items_dict[xml_data]
			for symbol_object in symbol_objects:
				var symbol_item = add_symbol_on_tree(xml_item, symbol_object)
				symbol_items_dict[symbol_object] = symbol_item


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
# Received Event Handle---------------------------------------
#-------------------------------------------------------------			
func _select_symbol(symbol_object: SymbolObject):
	var symbol_item = symbol_items_dict[symbol_object]
	if not symbol_item.is_selected(0):
		symbol_item.select(0) 
		tree.scroll_to_item(symbol_item, true)
	
	
func _deselect_symbol(symbol_object: SymbolObject):
	tree.deselect_all()

	
func _add_symbol(symbol_object: SymbolObject):
	var xml_tree = xml_items_dict[symbol_object.source_xml]
	var symbol_item = add_symbol_on_tree(xml_tree, symbol_object)
	symbol_items_dict[symbol_object] = symbol_item
	
	
func _remove_symbol(symbol_object: SymbolObject):
	var symbol_item = symbol_items_dict[symbol_object]
	tree.remove_child(symbol_item)
	symbol_item.free()


func _edit_symbol(symbol_object: SymbolObject):
	var symbol_item = symbol_items_dict[symbol_object]
	fill_treeitem(symbol_item, symbol_object)


func _change_visibility(xml_data: XMLData):
	xml_items_dict[xml_data].collapsed = not xml_data.is_visible
			
			
func _change_selectability(xml_data: XMLData):
	for symbol_object in xml_data.symbol_objects:
		for i in range(COLUMN_COUNT):
			symbol_items_dict[symbol_object].set_selectable(i,xml_data.is_selectable)
