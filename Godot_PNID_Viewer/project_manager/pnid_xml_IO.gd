class_name PnidXmlIo

enum XMLFORMAT {TWOPOINT, FOURPOINT, UNKNOWN}


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
		
		
static func parse_pnid_data_from_string(contents: String, format: String, img_filename: String, img_width: int, img_height: int) -> Array[SymbolObject]:
	if format == "XML":
		var xml_type = check_xml_type(contents)
		assert(xml_type != XMLFORMAT.UNKNOWN, "Error: Unknown data format")
		if xml_type == XMLFORMAT.TWOPOINT:
			return parse_twopoint_xml(contents)
	
	if format == "DOTA":
		return parse_dota_txt(contents)
		
	if format == "COCO":
		return parse_coco_json(contents, img_filename)
		
	if format == "YOLO":
		return parse_yolo_txt(contents, img_width, img_height)
		
	return []
	
static func parse_yolo_txt(contents: String, img_width: int, img_height: int) -> Array[SymbolObject]:
	var symbol_objects: Array[SymbolObject] = []
	var lines = contents.split("\n")
	
	var id = 0
	for line in lines:
		if line.is_empty():
			break
			
		var symbol_object = SymbolObject.new()
		symbol_object.id = id
		symbol_object.type = ""
		
		var elems = line.split(" ")
		var normalized_x = elems[1].to_float()
		var normalized_y = elems[2].to_float()
		var normalized_w = elems[3].to_float()
		var normalized_h = elems[4].to_float()
				
		var symbol_width = int(normalized_w * img_width)
		var symbol_height = int(normalized_h * img_height)
		var minx = int((normalized_x * img_width) - (symbol_width * 0.5))
		var miny = int((normalized_y * img_height) - (symbol_height * 0.5))
		var maxx = minx + symbol_width
		var maxy = miny + symbol_height
		
		symbol_object.cls = elems[0]
		var degree = elems[6].to_float() if len(elems) >= 6 else 0 # no degree for dota
		symbol_object.degree = degree
		var bndbox = Vector4(minx, miny, maxx, maxy)
		symbol_object.bndbox = bndbox
		symbol_object.flip = false
		symbol_objects.push_back(symbol_object)
		id += 1
		
	return symbol_objects	
	
	
static func parse_coco_json(contents: String, target_image_filename: String) -> Array[SymbolObject]:
	var symbol_objects: Array[SymbolObject] = []
	var symbol_id = 0
	
	var json = JSON.new()
	var error = json.parse(contents)
		
	var target_image_id
	if error == OK:
		var data_received = json.data
				
		var categories = data_received["categories"]
		
		for image_info in data_received["images"]:
			if image_info["file_name"] == target_image_filename:
				target_image_id = image_info["id"]
				break
		
		for annotation in data_received["annotations"]:
			if annotation["image_id"] == target_image_id:
				var symbol_object = SymbolObject.new()
				symbol_object.id = symbol_id
				symbol_object.type = annotation['attributes']['type']
				var category_id = int(annotation["category_id"])
				
				var matched_category = categories.filter(func(c): return int(c["id"]) == category_id)
				symbol_object.cls = matched_category[0]["name"] if not symbol_object.is_text else annotation['attributes']['text_string']
				var degree = annotation['attributes']['degree']
				symbol_object.degree = degree
				
				var bbox = annotation["bbox"]
				# x,y,w,h -> minx, miny, maxx, maxy
				var bndbox = Vector4(int(bbox[0]), int(bbox[1]), int(bbox[0]) + int(bbox[2]), int(bbox[1]) + int(bbox[3]))
				symbol_object.bndbox = bndbox
				symbol_object.flip = false
				symbol_objects.push_back(symbol_object)
				symbol_id += 1
		
		
	else:
		print("JSON Parse Error: ", json.get_error_message(), " at line ", json.get_error_line())
		return symbol_objects
	
	return symbol_objects	
	

static func parse_dota_txt(contents: String) -> Array[SymbolObject]:
	var symbol_objects: Array[SymbolObject] = []
	var lines = contents.split("\n")
	
	var id = 0
	for line in lines:
		if line.is_empty():
			break
			
		var symbol_object = SymbolObject.new()
		symbol_object.id = id
		symbol_object.type = ""
		
		var elems = line.split(" ")
		var p1 = Vector2(elems[0].to_float(), elems[1].to_float())
		var p2 = Vector2(elems[2].to_float(), elems[3].to_float())
		var p3 = Vector2(elems[4].to_float(), elems[5].to_float())
		var p4 = Vector2(elems[6].to_float(), elems[7].to_float())
		
		symbol_object.cls = elems[8]
		var degree = symbol_object.get_degree_from_dota_fourpoint(p1,p2,p3,p4)
		symbol_object.degree = degree
		var bndbox = symbol_object.get_bndbox_from_fourpoint_degree(p1,p2,p3,p4,degree)
		symbol_object.bndbox = bndbox
		symbol_object.flip = false
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
					id += 1
		if parser.get_node_type() == XMLParser.NODE_ELEMENT_END:
			var node_name = parser.get_node_name()
			if node_name == Config.OBJECT_TAG_NAME:
				symbol_objects.push_back(symbol_object)
					
	return symbol_objects

# TODO: separate DOTA/YOLO parse with explicit function calling
static func check_xml_type(contents: String) -> XMLFORMAT:
	var parser = XMLParser.new()
	parser.open_buffer(contents.to_utf8_buffer())
	
	while parser.read() != ERR_FILE_EOF:
		if parser.get_node_type() == XMLParser.NODE_ELEMENT:
			var node_name = parser.get_node_name()
			
			match node_name:
				"xmin":
					return XMLFORMAT.TWOPOINT
	
	# no longer supports other than 2point XML format
	return XMLFORMAT.UNKNOWN
	


static func dump_twopoint_pnid_xml(symbol_objects: Array[SymbolObject]) -> String:
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
	
static func dump_fourpoint_pnid_xml(symbol_objects: Array[SymbolObject]) -> String:
	var xml_str = String()
	
	xml_str += "<annotation>\r\n"
	for symbol_object in symbol_objects:
		if symbol_object.removed:
			continue
			
		var points = symbol_object.get_rotated_fourpoint()
		
		xml_str += "  <symbol_object>\r\n"
		xml_str += "    <type>%s</type>\r\n" % symbol_object.type
		xml_str += "    <class>%s</class>\r\n" % symbol_object.cls
		xml_str += "    <bndbox>\r\n"
		xml_str += "      <x1>%d</x1>\r\n" % points[0].x
		xml_str += "      <y1>%d</y1>\r\n" % points[0].y
		xml_str += "      <x2>%d</x2>\r\n" % points[1].x
		xml_str += "      <y2>%d</y2>\r\n" % points[1].y
		xml_str += "      <x3>%d</x3>\r\n" % points[2].x
		xml_str += "      <y3>%d</y3>\r\n" % points[2].y
		xml_str += "      <x4>%d</x4>\r\n" % points[3].x
		xml_str += "      <y4>%d</y4>\r\n" % points[3].y
		xml_str += "    </bndbox>\r\n"
		xml_str += "    <isLarge>%s</isLarge>\r\n" % bool_to_yn(symbol_object.is_large)
		xml_str += "    <degree>%d</degree>\r\n" % symbol_object.degree
		xml_str += "    <flip>%s</flip>\r\n" % bool_to_yn(symbol_object.flip)
		xml_str += "  </symbol_object>\r\n"
	
	xml_str += "</annotation>\r\n"
		
	return xml_str
