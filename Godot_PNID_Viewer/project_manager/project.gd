class_name Project

var id: int
# var undo_redo

var loaded: bool = false

var img_filename 
var img
var xml_status: Array[XML_Status]

func initialize(id, img_filename, img, num_xml, xml_filenames, xml_strs):
	self.id = id
	self.img_filename = img_filename
	self.img = img
	
	xml_status.clear()
	for i in range(num_xml):
		var xml_stat = XML_Status.new()
		xml_stat.initialize_by_xml_str(xml_status.size(), xml_filenames[i], xml_strs[i].to_utf8_buffer())
		xml_status.push_back(xml_stat)
			
	return true
	

func get_xml_id_from_filename(filename: String) -> int:
	for xml_stat in xml_status:
		if xml_stat.filename == filename:
			return xml_stat.id
			
	return -1

