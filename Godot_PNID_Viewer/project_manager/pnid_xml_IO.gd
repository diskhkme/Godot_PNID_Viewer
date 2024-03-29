class_name PnidXmlIo

enum XMLTYPE {TWOPOINT, FOURPOINT, UNKNOWN}


static func yes_no_to_bool(str: String) -> bool:
	if str == "y":
		return true
	elif str == "n":
		return false
	else:
		print("Wrong case")
		return false
		
static func bool_to_yn(b: bool) -> String:
	if b:
		return "y"
	else: 
		return "n"
	

static func get_current_node_data(parser: XMLParser) -> String:
	if parser.read() != ERR_FILE_EOF && parser.get_node_type() == XMLParser.NODE_TEXT:
		return parser.get_node_data()
		
	return ""
		
		
static func parse_pnid_xml_from_string(contents: String) -> Array[SymbolObject]:
	var xml_type = check_xml_type(contents)
	assert(xml_type != XMLTYPE.UNKNOWN, "Error: Unknown xml type")
	
	if xml_type == XMLTYPE.TWOPOINT:
		return parse_twopoint_xml(contents)
	elif xml_type == XMLTYPE.FOURPOINT:
		return parse_fourpoint_xml(contents)
		
	return []
	

static func parse_fourpoint_xml(contents: String) -> Array[SymbolObject]:
	var symbol_objects: Array[SymbolObject] = []
	var parser = XMLParser.new()
	parser.open_buffer(contents.to_utf8_buffer())
	
	var id = 0
	var symbol_object
	var p1
	var p2
	var p3
	var p4
	while parser.read() != ERR_FILE_EOF:
		if parser.get_node_type() == XMLParser.NODE_ELEMENT:
			var node_name = parser.get_node_name()
			
			match node_name:
				Config.OBJECT_TAG_NAME:
					symbol_object = SymbolObject.new()
					symbol_object.id = id
				"type":
					symbol_object.type = get_current_node_data(parser)
				"class":
					symbol_object.cls = get_current_node_data(parser)
				"bndbox":
					p1 = Vector2.ZERO
					p2 = Vector2.ZERO
					p3 = Vector2.ZERO
					p4 = Vector2.ZERO
				"x1":
					p1.x = get_current_node_data(parser).to_float()
				"y1":
					p1.y = get_current_node_data(parser).to_float()
				"x2":
					p2.x = get_current_node_data(parser).to_float()
				"y2":
					p2.y = get_current_node_data(parser).to_float()
				"x3":
					p3.x = get_current_node_data(parser).to_float()
				"y3":
					p3.y = get_current_node_data(parser).to_float()
				"x4":
					p4.x = get_current_node_data(parser).to_float()
				"y4":
					p4.y = get_current_node_data(parser).to_float()
				"degree":
					symbol_object.degree = get_current_node_data(parser).to_float()
					var bndbox = symbol_object.get_bndbox_from_fourpoint_degree(p1,p2,p3,p4,symbol_object.degree)
					symbol_object.bndbox = bndbox
					
				"flip":
					symbol_object.flip = yes_no_to_bool(get_current_node_data(parser))
					symbol_objects.push_back(symbol_object)
					id += 1
					
	return symbol_objects


static func parse_twopoint_xml(contents: String) -> Array[SymbolObject]:
	var symbol_objects: Array[SymbolObject] = []
	var parser = XMLParser.new()
	parser.open_buffer(contents.to_utf8_buffer())
	
	var id = 0
	var symbol_object
	while parser.read() != ERR_FILE_EOF:
		if parser.get_node_type() == XMLParser.NODE_ELEMENT:
			var node_name = parser.get_node_name()
			
			match node_name:
				Config.OBJECT_TAG_NAME:
					symbol_object = SymbolObject.new()
					symbol_object.id = id
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
					symbol_objects.push_back(symbol_object)
					id += 1
					
	return symbol_objects

	
static func check_xml_type(contents: String) -> XMLTYPE:
	var parser = XMLParser.new()
	parser.open_buffer(contents.to_utf8_buffer())
	
	while parser.read() != ERR_FILE_EOF:
		if parser.get_node_type() == XMLParser.NODE_ELEMENT:
			var node_name = parser.get_node_name()
			
			match node_name:
				"xmin":
					return XMLTYPE.TWOPOINT
				"x1":
					return XMLTYPE.FOURPOINT
	
	return XMLTYPE.UNKNOWN
	


static func dump_pnid_xml(symbol_objects: Array[SymbolObject]) -> String:
	var xml_str = String()
	
	xml_str += "<annotation>\r\n"
	for symbol_object in symbol_objects:
		xml_str += "  <symbol_object>\r\n"
		xml_str += "    <type>%s</type>\r\n" % symbol_object.type
		xml_str += "    <class>%s</class>\r\n" % symbol_object.cls
		xml_str += "    <bndbox>\r\n"
		xml_str += "      <xmin>%d</xmin>\r\n" % symbol_object.bndbox.x
		xml_str += "      <ymin>%d</ymin>\r\n" % symbol_object.bndbox.y
		xml_str += "      <xmax>%d</xmax>\r\n" % symbol_object.bndbox.z
		xml_str += "      <ymax>%d</ymax>\r\n" % symbol_object.bndbox.w
		xml_str += "    </bndbox>\r\n"
		xml_str += "    <isLarge>%s</isLarge>\r\n" % bool_to_yn(symbol_object.is_large)
		xml_str += "    <degree>%d</degree>\r\n" % symbol_object.degree
		xml_str += "    <flip>%s</flip>\r\n" % bool_to_yn(symbol_object.flip)
		xml_str += "  </symbol_object>\r\n"
	
	xml_str += "</annotation>\r\n"
		
	return xml_str
	
