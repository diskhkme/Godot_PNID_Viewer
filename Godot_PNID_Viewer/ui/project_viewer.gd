extends PanelContainer

@onready var tree = $Tree
@onready var symbol_edit_interface = $SymbolEditInterface

@export var visibility_button_texture: Texture2D
@export var color_button_texture: Texture2D



func _ready():
	symbol_edit_interface.symbol_edited_received.connect(update_xml_status)
		

func use_project(project: Project) -> void:
	tree.clear()
	tree.set_columns(3)
	var root = tree.create_item()
	root.set_text(0,project.img_filepath.get_file())
	for xml_stat in project.xml_status:
		var child: TreeItem = tree.create_item(root)
		child.set_text(0,xml_stat.filename)
		child.set_text(1, "visibile")
		child.set_cell_mode(1, TreeItem.CELL_MODE_CHECK)
		
		
# TODO: Connect options to viewer (Show/Hide, Color Pick)

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

