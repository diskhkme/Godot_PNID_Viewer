class_name Project

var id: int
# var undo_redo

var loaded: bool = false

var img_filename: String
var img: Image
var xml_datas: Array[XMLData]

func initialize(id, img_filename, img, num_xml, xml_filenames, xml_strs):
	self.id = id
	self.img_filename = img_filename
	self.img = img
	
	xml_datas.clear()
	for i in range(num_xml):
		var xml_data = XMLData.new()
		xml_data.initialize_from_xml_str(xml_datas.size(), xml_filenames[i], xml_strs[i].to_utf8_buffer())
		xml_datas.push_back(xml_data)
			
	return true
	

func get_xml_id_from_filename(filename: String) -> int:
	for xml_data in xml_datas:
		if xml_data.filename == filename:
			return xml_data.id
			
	return -1


func add_xml_from_data(xml_data: XMLData):
	xml_datas.push_back(xml_data)
	SignalManager.xml_added.emit(xml_data)
	
	
func add_xml_from_file(num_xml, xml_filenames, xml_strs):
	for i in range(num_xml):
		var xml_data = XMLData.new()
		xml_data.initialize_from_xml_str(xml_datas.size(), xml_filenames[i], xml_strs[i].to_utf8_buffer())
		xml_datas.push_back(xml_data)
		SignalManager.xml_added.emit(xml_data)
	
