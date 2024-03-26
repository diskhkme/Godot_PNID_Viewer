# XML Tree Viewer
# Display symbol information of the middle right table-like GUI

extends Control
class_name XMLTreeViewer

signal symbol_selected(symbol_object: SymbolObject, from_tree: bool)
#signal symbol_deselected(symbol_object: SymbolObject, edited: bool)

@onready var tree = $Tree

@export var ColorIcon = preload("res://assets/icons/rectangle_tool.png")

var _xml_items_dict = {} # xml_data : tree_item
var _symbol_items_dict = {} # symbol_object: tree_item
var _root
#var selected_symbol

const COLUMN_COUNT = 8

func _ready():
	reset_tree()

#-------------------------------------------------------------
# Tree Initialization-----------------------------------------
#-------------------------------------------------------------
func use_project(project: Project):
	reset_tree()
	_symbol_items_dict.clear()
	_xml_items_dict.clear()

	for xml_data in project.xml_datas:
		var xml_item = add_xml_on_tree(xml_data)
		for symbol_object in xml_data.symbol_objects:
			var symbol_item = add_symbol_on_tree(xml_item, symbol_object)
			_symbol_items_dict[symbol_object] = symbol_item
		
		update_xml_visibility(xml_data)
		update_xml_selectability(xml_data)	
		
		
func close_project(project: Project):
	reset_tree()
	_symbol_items_dict.clear()
	_xml_items_dict.clear()


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
			
	_root = tree.create_item() 
	tree.hide_root = true


func add_xml_on_tree(xml_data: XMLData) -> TreeItem:
	var xml_item = tree.create_item(_root)
	xml_item.set_text(0,xml_data.filename)
	for i in range(COLUMN_COUNT):
		xml_item.set_selectable(i, false)
		
	_xml_items_dict[xml_data] = xml_item		
	return xml_item
	
	
func fill_treeitem(symbol_child: TreeItem, symbol_object: SymbolObject):
	if symbol_object.dirty:
		if symbol_object.removed:
			symbol_child.set_text(0, "(-)" + "%04d  " % symbol_object.id)
		else:
			symbol_child.set_text(0, "(*)" + "%04d  " % symbol_object.id)
	else:
		symbol_child.set_text(0, "%04d  " % symbol_object.id)
	symbol_child.set_text(1, symbol_object.type)
	symbol_child.set_text(2, symbol_object.cls)
	symbol_child.set_text(3, str(floor(symbol_object.bndbox.x)))
	symbol_child.set_text(4, str(floor(symbol_object.bndbox.y)))
	symbol_child.set_text(5, str(floor(symbol_object.bndbox.z)))
	symbol_child.set_text(6, str(floor(symbol_object.bndbox.w)))
	symbol_child.set_text(7, str(symbol_object.degree))

	
func add_symbol_on_tree(parent: TreeItem, symbol_object: SymbolObject) -> TreeItem:
	var symbol_item: TreeItem = tree.create_item(parent)
	fill_treeitem(symbol_item,symbol_object)
	symbol_item.set_custom_color(0, symbol_object.origin_xml.color)
	symbol_item.set_text_alignment(0, HORIZONTAL_ALIGNMENT_RIGHT)
	if symbol_object.is_text:
		# TODO: text editing does not signal symbol edited
		symbol_item.set_editable(2, true)
		
	return symbol_item
		
		
func select_symbol(symbol_object: SymbolObject):
	var symbol_item = _symbol_items_dict[symbol_object]
	if not symbol_item.is_selected(0):
		symbol_item.select(0) 
		tree.scroll_to_item(symbol_item, true)
	
	
func deselect_symbol():
	tree.deselect_all()
	
	
func scroll_to_xml(xml_data: XMLData):
	tree.scroll_to_item(_xml_items_dict[xml_data], true)
		
#-------------------------------------------------------------
# Self Event Handle  -----------------------------------------
#-------------------------------------------------------------
func _on_tree_item_selected():
	var selected_item = tree.get_selected()
	var selected_symbols = _symbol_items_dict.keys().filter(func(a): return _symbol_items_dict[a] == selected_item)
	#selected_symbol = selected_symbols[0]
	symbol_selected.emit(selected_symbols[0], true)
	

func _on_tree_column_title_clicked(column, mouse_button_index):
	if mouse_button_index == MOUSE_BUTTON_LEFT:
		for prev_symbol_item in _symbol_items_dict.values():
			prev_symbol_item.free()
		
		for xml_data in _xml_items_dict.keys():
			var symbol_objects = xml_data.symbol_objects
			symbol_objects.sort_custom(sort_function(column))
			var xml_item = _xml_items_dict[xml_data]
			for symbol_object in symbol_objects:
				var symbol_item = add_symbol_on_tree(xml_item, symbol_object)
				_symbol_items_dict[symbol_object] = symbol_item
				
			update_xml_visibility(xml_data)


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
			
			
#-------------------------------------------------------------
# Received Event Handle---------------------------------------
#-------------------------------------------------------------			
func apply_symbol_change(symbol_object: SymbolObject):
	var xml_tree = _xml_items_dict[symbol_object.source_xml]
	if _symbol_items_dict.has(symbol_object):
		var symbol_item = _symbol_items_dict[symbol_object]
		if symbol_object.source_xml.symbol_objects.has(symbol_object): # edited case
			fill_treeitem(symbol_item, symbol_object)
		else: # undo add case
			xml_tree.remove_child(symbol_item)
			symbol_item.free()
			_symbol_items_dict.erase(symbol_object)
	else: # add case
		var symbol_item = add_symbol_on_tree(xml_tree, symbol_object)
		_symbol_items_dict[symbol_object] = symbol_item
		tree.scroll_to_item(_symbol_items_dict[symbol_object], true)


func update_xml_visibility(xml_data: XMLData):
	_symbol_items_dict.keys().map(func(s): 
		if s.source_xml == xml_data:
			if s.is_text:
				if xml_data.is_text_visible:
					_symbol_items_dict[s].visible = true
				else:
					_symbol_items_dict[s].visible = false
			else:
				if xml_data.is_symbol_visible:
					_symbol_items_dict[s].visible = true
				else:
					_symbol_items_dict[s].visible = false)
			
			
func update_xml_selectability(xml_data: XMLData):
	for symbol_object in xml_data.symbol_objects:
		for i in range(COLUMN_COUNT):
			_symbol_items_dict[symbol_object].set_selectable(i,xml_data.is_selectable)
