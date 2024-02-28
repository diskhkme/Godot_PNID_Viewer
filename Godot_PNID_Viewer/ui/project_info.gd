extends PanelContainer

@onready var tree = $Tree

@export var visibility_button_texture: Texture2D
@export var color_button_texture: Texture2D

func use_project(project: Project) -> void:
	tree.set_columns(3)
	var root = tree.create_item()
	root.set_text(0,project.img_filepath.get_file())
	for xml_stat in project.xml_status:
		var child: TreeItem = tree.create_item(root)
		child.set_text(0,xml_stat.filename)
		child.set_text(1, "visibile")
		child.set_cell_mode(1, TreeItem.CELL_MODE_CHECK)
		
		
# TODO: Connect options to viewer (Show/Hide, Color Pick)

