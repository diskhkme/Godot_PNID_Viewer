extends PanelContainer

signal xml_visibility_changed(xml_id: int)
signal xml_selectability_changed(xml_id: int)

@onready var tree = $Tree

@export var icon_color = preload("res://assets/icons/rectangle_tool.png")

var xml_file_items = {} # key: treeitem, value: xml_status

func _ready():
	SymbolManager.symbol_edited.connect(update_xml_status)
		

func use_project(project: Project) -> void:
	xml_file_items.clear()
	tree.clear()
	tree.set_columns(4)
	var root = tree.create_item()
	root.set_text(0,project.img_filepath.get_file())
	root.set_text(1, "Show")
	root.set_text(2, "Selectable")
	root.set_text(3, "Color")
	for xml_stat in project.xml_status:
		var child: TreeItem = tree.create_item(root)
		child.set_text(0,xml_stat.filename)
		child.set_cell_mode(1, TreeItem.CELL_MODE_CHECK)
		child.set_editable(1, true)
		child.set_cell_mode(2, TreeItem.CELL_MODE_CHECK)
		child.set_editable(2, true)
		child.set_cell_mode(3, TreeItem.CELL_MODE_ICON)
		child.set_icon_modulate(3,xml_stat.color)
		child.set_icon(3, icon_color)
		child.set_editable(3, true)
		
		child.set_checked(1, true)
		child.set_checked(2, true)
		
		xml_file_items[child] = xml_stat


func update_xml_status(xml_id:int, symbol_id:int):
	var xml_stat = ProjectManager.active_project.xml_status[xml_id]
	var root: TreeItem = tree.get_root()
	for i in range(root.get_child_count()):
		var child = root.get_child(i)
		if child.get_text(0).contains(xml_stat.filename):
			if xml_stat.dirty == true:
				child.set_text(0,xml_stat.filename + " (*)")
			else:
				child.set_text(0,xml_stat.filename)


func _process(delta): # TODO: how to receive treeitem checkbox changed event?
	for item in xml_file_items:
		if item.is_checked(1) != xml_file_items[item].is_visible:
			xml_file_items[item].is_visible = item.is_checked(1)
			xml_visibility_changed.emit(xml_file_items[item].id)
			if item.is_checked(1) == false: # if not visible, not selectable
				item.set_checked(2,false)
				item.set_editable(2,false)
			else:
				item.set_checked(2,true)
				item.set_editable(2,true)
			
		if item.is_checked(2) != xml_file_items[item].is_selectable:
			xml_file_items[item].is_selectable = item.is_checked(2)
			xml_selectability_changed.emit(xml_file_items[item].id)
		
