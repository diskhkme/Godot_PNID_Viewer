extends PanelContainer
class_name ProjectViewer

@onready var _tree = $Tree

@export var ColorIcon = preload("res://assets/icons/rectangle_tool.png")

const COLUMN_NUM = 6

var _tree_item_dict = {} # key: xml_item, value: xml_data
var _root: TreeItem
var _selected_xml: XMLData

func _ready():
	SignalManager.symbol_edited.connect(_update_dirty)
	
	
func use_project(project: Project) -> void:
	_tree_item_dict.clear()
	_tree.clear()
	_reset_tree(project)
	update_dirty()
	
	
func _reset_tree(project: Project):
	reset_root(project.img_filename)
	for xml_data in project.xml_datas:
		reset_xml(xml_data)
	
	
func reset_root(img_filename: String):
	_tree.set_columns(COLUMN_NUM)
	_root = _tree.create_item()
	_root.set_text(0, img_filename)
	# TODO: Show symbol & text separately
	_root.set_text(1, "Show")
	_root.set_text(2, "Select")
	_root.set_text(3, "Label")
	_root.set_text(4, "Color")
	
	
func reset_xml(xml_data: XMLData):
	var xml_item: TreeItem = _tree.create_item(_root)
	xml_item.set_text(0,xml_data.filename)
	for i in range(3):
		xml_item.set_cell_mode(i+1, TreeItem.CELL_MODE_CHECK)
		xml_item.set_editable(i+1, true)
		xml_item.set_selectable(i+1, false)	
	
	# Color
	var colors = xml_data.get_colors()
	var ind = 0
	for color in colors:
		xml_item.set_cell_mode(ind+4, TreeItem.CELL_MODE_ICON)
		xml_item.set_icon_modulate(ind+4, color)
		xml_item.set_icon(ind+4, ColorIcon)
		ind += 1
		
	xml_item.set_checked(1, xml_data.is_visible)
	xml_item.set_checked(2, xml_data.is_selectable)
	xml_item.set_checked(3, xml_data.is_show_label)
	_tree_item_dict[xml_item] = xml_data
	
	

	


	
	
func update_dirty():
	for xml_item in _tree_item_dict:
		if _tree_item_dict[xml_item].dirty == true:
			xml_item.set_text(0,_tree_item_dict[xml_item].filename + " (*)")
		else:
			xml_item.set_text(0,_tree_item_dict[xml_item].filename)


func _update_dirty(symbol_object: SymbolObject):
	update_dirty()
		

# TODO: how to receive treeitem checkbox changed event?
func _process(delta): 
	for xml_item in _tree_item_dict:
		var xml_data = _tree_item_dict[xml_item]
		if xml_item.is_checked(1) != xml_data.is_visible:
			xml_data.is_visible = xml_item.is_checked(1)
			SignalManager.xml_visibility_changed.emit(xml_data)
			if xml_item.is_checked(1) == false: # if not visible, not selectable
				xml_item.set_checked(2,false)
				xml_item.set_editable(2,false)
				xml_item.set_checked(3,false)
				xml_item.set_editable(3,false)
			else:
				xml_item.set_editable(2,true)
				xml_item.set_editable(3,true)
			
		if xml_item.is_checked(2) != xml_data.is_selectable:
			if !xml_item.is_checked(1): # not allow selectable if not visible
				xml_item.set_checked(2,false)
			xml_data.is_selectable = xml_item.is_checked(2)
			SignalManager.xml_selectability_changed.emit(xml_data)
			
		if xml_item.is_checked(3) != xml_data.is_show_label:
			if !xml_item.is_checked(1): # not allow selectable if not visible
				xml_item.set_checked(3,false)
			xml_data.is_show_label = xml_item.is_checked(3)
			SignalManager.xml_label_visibility_changed.emit(xml_data)
		

func _on_tree_item_selected():
	var selected_item = _tree.get_selected()
	_selected_xml = _tree_item_dict[selected_item]


func _on_tree_nothing_selected():
	_selected_xml = null
	_tree.deselect_all()
