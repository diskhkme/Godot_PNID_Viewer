extends PanelContainer

signal xml_visibility_changed(xml_id: int)
signal xml_selectability_changed(xml_id: int)

@onready var tree = $Tree

@export var icon_color = preload("res://assets/icons/rectangle_tool.png")

var tree_xml_dict = {} # key: xml_id, value: [xml_stat, xml_item]
var root
var selected

func _ready():
	SymbolManager.symbol_edited.connect(_on_symbol_edited)
	
	
func reset_root(img_filename: String):
	tree.set_columns(4)
	root = tree.create_item()
	root.set_text(0, img_filename)
	# TODO: Show symbol & text separately
	root.set_text(1, "Show")
	root.set_text(2, "Selectable")
	root.set_text(3, "Color")
	
	
func reset_xml(xml_stat: XML_Status):
	var xml_item: TreeItem = tree.create_item(root)
	xml_item.set_text(0,xml_stat.filename)
	xml_item.set_cell_mode(1, TreeItem.CELL_MODE_CHECK)
	xml_item.set_editable(1, true)
	xml_item.set_cell_mode(2, TreeItem.CELL_MODE_CHECK)
	xml_item.set_editable(2, true)
	xml_item.set_cell_mode(3, TreeItem.CELL_MODE_ICON)
	xml_item.set_icon_modulate(3,xml_stat.color)
	xml_item.set_icon(3, icon_color)
	xml_item.set_editable(3, true)
	
	xml_item.set_checked(1, xml_stat.is_visible)
	xml_item.set_checked(2, xml_stat.is_selectable)
	tree_xml_dict[xml_stat.id] = [xml_stat, xml_item]
	
	
func reset_tree(project: Project):
	reset_root(project.img_filename)
	for xml_stat in project.xml_status:
		reset_xml(xml_stat)
	

func use_project(project: Project) -> void:
	tree_xml_dict.clear()
	tree.clear()
	reset_tree(project)
	

# TODO: dirty state is not maintained when active project changed
func _on_symbol_edited(xml_id:int, symbol_id:int):
	var target_xml_stat = tree_xml_dict[xml_id][0]
	if target_xml_stat.dirty == true:
		tree_xml_dict[xml_id][1].set_text(0,target_xml_stat.filename + " (*)")
	else:
		tree_xml_dict[xml_id][1].set_text(0,target_xml_stat.filename)
		

# TODO: how to receive treeitem checkbox changed event?
func _process(delta): 
	for xml_id in tree_xml_dict:
		var xml_stat = tree_xml_dict[xml_id][0]
		var xml_item = tree_xml_dict[xml_id][1]
		if xml_item.is_checked(1) != xml_stat.is_visible:
			xml_stat.is_visible = xml_item.is_checked(1)
			if xml_item.is_checked(1) == false: # if not visible, not selectable
				xml_item.set_checked(2,false)
				xml_item.set_editable(2,false)
			else:
				xml_item.set_checked(2,true)
				xml_item.set_editable(2,true)
				
			xml_visibility_changed.emit(xml_id)
			
		if xml_item.is_checked(2) != xml_stat.is_selectable:
			if !xml_item.is_checked(1): # not allow selectable if not visible
				return
			xml_stat.is_selectable = xml_item.is_checked(2)
			xml_selectability_changed.emit(xml_id)
		

func _on_tree_item_selected():
	selected = tree.get_selected()


func _on_tree_nothing_selected():
	selected = null
