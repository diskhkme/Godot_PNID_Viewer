extends PanelContainer
class_name ProjectViewer

@onready var tree = $Tree

@export var color_icon = preload("res://assets/icons/rectangle_tool.png")

const COLUMN_NUM = 5

var tree_xml_dict = {} # key: xml_item, value: xml_data
var root
var selected_xml

func _ready():
	SignalManager.symbol_edited.connect(_update_dirty)
	
	
func reset_root(img_filename: String):
	tree.set_columns(COLUMN_NUM)
	root = tree.create_item()
	root.set_text(0, img_filename)
	# TODO: Show symbol & text separately
	root.set_text(1, "Show")
	root.set_text(2, "Selectable")
	root.set_text(3, "Color")
	
	
func reset_xml(xml_data: XMLData):
	var xml_item: TreeItem = tree.create_item(root)
	xml_item.set_text(0,xml_data.filename)
	xml_item.set_cell_mode(1, TreeItem.CELL_MODE_CHECK)
	xml_item.set_editable(1, true)
	xml_item.set_selectable(1, false)
	xml_item.set_cell_mode(2, TreeItem.CELL_MODE_CHECK)
	xml_item.set_editable(2, true)
	xml_item.set_selectable(2, false)

	var ind = 0
	for color in xml_data.colors.keys():
		xml_item.set_cell_mode(ind+3, TreeItem.CELL_MODE_ICON)
		xml_item.set_icon_modulate(ind+3, color)
		xml_item.set_icon(ind+3, color_icon)
		ind += 1
	
	xml_item.set_checked(1, xml_data.is_visible)
	xml_item.set_checked(2, xml_data.is_selectable)
	tree_xml_dict[xml_item] = xml_data
	
	
func reset_tree(project: Project):
	reset_root(project.img_filename)
	for xml_data in project.xml_datas:
		reset_xml(xml_data)
	

func use_project(project: Project) -> void:
	tree_xml_dict.clear()
	tree.clear()
	reset_tree(project)
	update_dirty()
	
	
func update_dirty():
	for xml_item in tree_xml_dict:
		if tree_xml_dict[xml_item].dirty == true:
			xml_item.set_text(0,tree_xml_dict[xml_item].filename + " (*)")
		else:
			xml_item.set_text(0,tree_xml_dict[xml_item].filename)


func _update_dirty(symbol_object: SymbolObject):
	update_dirty()
		

# TODO: how to receive treeitem checkbox changed event?
func _process(delta): 
	for xml_item in tree_xml_dict:
		var xml_data = tree_xml_dict[xml_item]
		if xml_item.is_checked(1) != xml_data.is_visible:
			xml_data.is_visible = xml_item.is_checked(1)
			if xml_item.is_checked(1) == false: # if not visible, not selectable
				xml_item.set_checked(2,false)
				xml_item.set_editable(2,false)
			else:
				xml_item.set_checked(2,true)
				xml_item.set_editable(2,true)
				
			SignalManager.xml_visibility_changed.emit(xml_data)
			
		if xml_item.is_checked(2) != xml_data.is_selectable:
			if !xml_item.is_checked(1): # not allow selectable if not visible
				xml_item.set_checked(2,false)
			xml_data.is_selectable = xml_item.is_checked(2)
			SignalManager.xml_selectability_changed.emit(xml_data)
		

func _on_tree_item_selected():
	var selected_item = tree.get_selected()
	selected_xml = tree_xml_dict[selected_item]


func _on_tree_nothing_selected():
	selected_xml = null
	tree.deselect_all()
