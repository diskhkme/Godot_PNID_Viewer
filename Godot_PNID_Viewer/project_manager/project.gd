class_name Project

var id: int
# var undo_redo

var dirty: bool = false # TODO: per xml dirty state
var loaded: bool = false

var img_filepath: String 
var xml_status: Array[XML_Status]

func initialize(id: int, paths: PackedStringArray) -> bool:
	id = id
	img_filepath = Util.get_img_path(paths)
	if img_filepath.is_empty():
		return false
	
	var xml_filepaths = Util.get_xml_paths(paths)
	if xml_filepaths.size() > 0:
		for xml_path in xml_filepaths:
			add_xml_status(xml_path)
			
	return true
	

func add_xml_status(xml_path: String) -> void:
	var id = xml_status.size()
	var xml_stat = XML_Status.new(id, xml_path)
	xml_status.push_back(xml_stat)
		

func get_xml_id_from_filename(filename: String) -> int:
	for xml_stat in xml_status:
		if xml_stat.filename == filename:
			return xml_stat.id
			
	return -1

