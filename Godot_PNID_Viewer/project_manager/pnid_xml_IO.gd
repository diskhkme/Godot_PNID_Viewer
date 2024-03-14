class_name PnidXmlIo

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
		
		
static func parse_pnid_xml_from_byte_array(contents: PackedByteArray) -> Array[SymbolObject]:
	var symbol_objects: Array[SymbolObject] = []
	
	var parser = XMLParser.new()
	parser.open_buffer(contents)
	
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


static func dump_pnid_xml(symbol_objects: Array[SymbolObject]) -> String:
	var xml_str = String()
	
	xml_str += "<annotation>\r\n"
	for symbol_object in symbol_objects:
		if symbol_object.removed:
			continue
		
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
	