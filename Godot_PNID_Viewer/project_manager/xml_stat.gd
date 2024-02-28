class_name XML_Status

var id: int
var path: String
var filename: String

var symbol_objects: Array

var visible: bool
var color: Color

func _init(id, path):
	self.id = id
	self.path = path
	filename = path.get_file()
	symbol_objects = PnidXmlParser.parse_pnid_xml(path)
	visible = true
	color = Config.project_color_preset[id]
