class_name XML_Status

var id: int
var path: String
var filename: String

var symbol_objects: Array

var visible: bool
var color: Color

var dirty: bool

func _init(id, path):
	self.id = id
	self.path = path
	filename = path.get_file()
	symbol_objects = PnidXmlParser.parse_pnid_xml(path)
	var is_sane = check_sanity(symbol_objects) # TODO: what to do if check sanity failes?
	visible = true
	color = Config.project_color_preset[id]
	

# TODO: add more constraints
func check_sanity(symbol_objects):
	for symbol_object in symbol_objects:
		if !ProjectManager.symbol_type_set.has(symbol_object.type):
			return false
			print("XML has undefined symbol type!")
		if !symbol_object.is_text:
			if !ProjectManager.symbol_type_set[symbol_object.type].has(symbol_object.cls):
				return false
				print("XML has undefined symbol type!")

	return true
