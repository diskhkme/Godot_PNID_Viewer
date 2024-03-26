extends PanelContainer
class_name ProjectViewer

signal xml_selected(xml_data: XMLData)
signal xml_deselected
signal xml_visibility_changed(xml_data: XMLData, is_text: bool, enabled: bool)
signal xml_selectability_changed(xml_data: XMLData, enabled: bool)
signal xml_label_visibility_changed(xml_data: XMLData, enabled: bool)

@onready var _tree = $Tree

@export var ColorIcon = preload("res://assets/icons/rectangle_tool.png")

const COLUMN_COUNT = 6

var _tree_item_dict = {} # key: xml_item, value: xml_data
var _root: TreeItem
var selected_xml: XMLData

func use_project(project: Project) -> void:
	_tree_item_dict.clear()
	_tree.clear()
	_reset_tree(project)
	update_dirty()
	
	
func close_project(project: Project):
	_tree_item_dict.clear()
	_tree.clear()
	
	
func select_xml(xml_data: XMLData):
	var target_item = _tree_item_dict.keys().filter(func(d): return _tree_item_dict[d] == xml_data)
	target_item[0].select(0)
	
	
func _reset_tree(project: Project):
	reset_root(project.img_filename)
	for xml_data in project.xml_datas:
		reset_xml(xml_data)
	
	
func reset_root(img_filename: String):
	_tree.set_columns(COLUMN_COUNT)
	_root = _tree.create_item()
	_root.set_text(0, img_filename)
	# TODO: Show symbol & text separately
	_root.set_text(1, "Symbol")
	_root.set_text(2, "Text")
	_root.set_text(3, "Select")
	_root.set_text(4, "Label")
	_root.set_text(5, "Color")
	for i in range(1,COLUMN_COUNT):
		_tree.set_column_expand(i, false)
		_tree.set_column_custom_minimum_width(i,50)
	
	
func reset_xml(xml_data: XMLData):
	var xml_item: TreeItem = _tree.create_item(_root)
	xml_item.set_text(0,xml_data.filename)
	for i in range(1,5):
		xml_item.set_cell_mode(i, TreeItem.CELL_MODE_CHECK)
		xml_item.set_editable(i, true)
		xml_item.set_selectable(i, false)
		xml_item.set_text_alignment(i, HORIZONTAL_ALIGNMENT_CENTER)
	
	if xml_data is XMLData:
		xml_item.set_cell_mode(5, TreeItem.CELL_MODE_ICON)
		xml_item.set_icon_modulate(5, xml_data.color)
		xml_item.set_icon(5, ColorIcon)
		
	xml_item.set_checked(1, xml_data.is_symbol_visible)
	xml_item.set_checked(2, xml_data.is_text_visible)
	xml_item.set_checked(3, xml_data.is_selectable)
	xml_item.set_checked(4, xml_data.is_show_label)
	_tree_item_dict[xml_item] = xml_data
	
	if xml_data is DiffData:
		var source_xml_item: TreeItem = _tree.create_item(xml_item)
		source_xml_item.set_text(0, xml_data.source_xml.filename)
		source_xml_item.set_cell_mode(4, TreeItem.CELL_MODE_ICON)
		source_xml_item.set_icon_modulate(4, xml_data.source_xml.color)
		source_xml_item.set_icon(4, ColorIcon)
		var target_xml_item: TreeItem = _tree.create_item(xml_item)
		target_xml_item.set_text(0, xml_data.target_xml.filename)
		target_xml_item.set_cell_mode(4, TreeItem.CELL_MODE_ICON)
		target_xml_item.set_icon_modulate(4, xml_data.target_xml.color)
		target_xml_item.set_icon(4, ColorIcon)
	
		
func update_dirty():
	for xml_item in _tree_item_dict:
		if _tree_item_dict[xml_item].dirty:
			xml_item.set_text(0,"(*)"+_tree_item_dict[xml_item].filename)
		else:
			xml_item.set_text(0,_tree_item_dict[xml_item].filename)
		

# TODO: how to receive treeitem checkbox changed event?
func _process(delta): 
	for xml_item in _tree_item_dict:
		var xml_data = _tree_item_dict[xml_item]
		if xml_item.is_checked(1) != xml_data.is_symbol_visible:
			xml_visibility_changed.emit(xml_data, false, xml_item.is_checked(1))
		if xml_item.is_checked(2) != xml_data.is_text_visible:
			xml_visibility_changed.emit(xml_data, true, xml_item.is_checked(2))
			
		if not xml_item.is_checked(1) and not xml_item.is_checked(2):
			xml_item.set_checked(3,false)
			xml_item.set_editable(3,false)
			xml_item.set_checked(4,false)
			xml_item.set_editable(4,false)
		else:
			xml_item.set_editable(3,true)
			xml_item.set_editable(4,true)
			
		if xml_item.is_checked(3) != xml_data.is_selectable:
			xml_selectability_changed.emit(xml_data, xml_item.is_checked(3))
			
		if xml_item.is_checked(4) != xml_data.is_show_label:
			xml_label_visibility_changed.emit(xml_data, xml_item.is_checked(4))
		

func _on_tree_item_selected():
	var selected_item = _tree.get_selected()
	if not _tree_item_dict.has(selected_item):
		return
	selected_xml = _tree_item_dict[selected_item]
	xml_selected.emit(selected_xml)


func _on_tree_nothing_selected():
	selected_xml = null
	_tree.deselect_all()
	
	
func save_xml(path: String):
	if !path.contains(".xml"):
		path += ".xml"
		
	var xml_dump = PnidXmlIo.dump_pnid_xml(selected_xml.symbol_objects)
	if OS.get_name() == "Windows":
		var file = FileAccess.open(path, FileAccess.WRITE)
		file.store_string(xml_dump)
