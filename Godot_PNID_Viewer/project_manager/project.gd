class_name Project

var id: int
# var undo_redo

var loaded: bool = false

var img_filename 
var img
var xml_status: Array[XML_Status]

func initialize(id, img_filename, img, xml_filenames, xml_strs):
	self.id = id
	self.img_filename = img_filename
	self.img = img
	
	#print(img)
	#print(xml_filenames)
	#print(xml_strs)
	
	xml_status.clear()
	for i in range(xml_strs.size()):
		var xml_stat = parse_xml_status(xml_filenames[i], xml_strs[i].to_utf8_buffer())
		xml_status.push_back(xml_stat)
			
	return true
	

func parse_xml_status(xml_filename:String, xml_str: PackedByteArray):
	var id = xml_status.size()
	var xml_stat = XML_Status.new(id, xml_filename, xml_str)
	return xml_stat
		

func get_xml_id_from_filename(filename: String) -> int:
	for xml_stat in xml_status:
		if xml_stat.filename == filename:
			return xml_stat.id
			
	return -1

