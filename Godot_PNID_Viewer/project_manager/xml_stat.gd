class_name XML_Status

var id: int
var path: String
var filename: String

var symbol_objects: Array

var visible: bool
var color: Color

var dirty: bool

var symbol_type_set = {} # TODO: replace to symboltype_class.txt
var symbol_cls_set = {}

func _init(id, path):
	self.id = id
	self.path = path
	filename = path.get_file()
	symbol_objects = PnidXmlParser.parse_pnid_xml(path)
	update_symbol_type_cls_cache(symbol_objects)
	visible = true
	color = Config.project_color_preset[id]


func update_symbol_type_cls_cache(symbol_objects: Array):
	for symbol_object in symbol_objects:
		if symbol_type_set.has(symbol_object.type):
			symbol_type_set[symbol_object.type] += 1
		else:
			symbol_type_set[symbol_object.type] = 0
			
		if !symbol_object.type.to_lower().contains("text"): # ignore text for cls cache
			if symbol_cls_set.has(symbol_object.cls):
				symbol_cls_set[symbol_object.cls] += 1
			else:
				symbol_cls_set[symbol_object.cls] = 0
				
				
func get_text_type_index():
	for i in range(symbol_type_set.size()):
		if symbol_type_set[i].to_lower().contains("text"):
			return i
			
	return -1
