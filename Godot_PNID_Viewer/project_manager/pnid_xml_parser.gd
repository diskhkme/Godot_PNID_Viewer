# PNID xml parser
# partse xml, symbolclass type

extends Node

func yes_no_to_bool(str: String) -> bool:
	if str == "y":
		return true
	elif str == "n":
		return false
	else:
		print("Wrong case")
		return false
	

func get_current_node_data(parser: XMLParser) -> String:
	if parser.read() != ERR_FILE_EOF && parser.get_node_type() == XMLParser.NODE_TEXT:
		return parser.get_node_data()
		
	return ""
		

func parse_pnid_xml(path: String) -> Array:
	var symbol_objects = Array()
	
	var parser = XMLParser.new()
	parser.open(path)
	
	var symbol_object = SymbolObject.new()
	while parser.read() != ERR_FILE_EOF:
		if parser.get_node_type() == XMLParser.NODE_ELEMENT:
			var node_name = parser.get_node_name()
			
			match node_name:
				Config.OBJECT_TAG_NAME:
					symbol_object = SymbolObject.new()
				"type":
					symbol_object.type = get_current_node_data(parser)
				"class":
					symbol_object.cls = get_current_node_data(parser)
				"bndbox":
					symbol_object.bndbox = Vector4()
				"xmin":
					symbol_object.bndbox.x = get_current_node_data(parser).to_float()
				"ymin":
					symbol_object.bndbox.y = get_current_node_data(parser).to_float()
				"xmax":
					symbol_object.bndbox.z = get_current_node_data(parser).to_float()
				"ymax":
					symbol_object.bndbox.w = get_current_node_data(parser).to_float()
				"isLarge":
					symbol_object.is_large = yes_no_to_bool(get_current_node_data(parser))
				"degree":
					symbol_object.degree = get_current_node_data(parser).to_float()
				"flip":
					symbol_object.flip = yes_no_to_bool(get_current_node_data(parser))
					symbol_object.id = symbol_objects.size()
					symbol_objects.push_back(symbol_object)
					
	return symbol_objects
		
		
