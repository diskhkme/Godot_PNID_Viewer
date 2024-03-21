extends Node

signal project_files_opened(args: Variant)
signal xml_files_opened(args: Variant)

# In web build, callback of getFile(implemented in "header include" of build setting) is
# designated to webFileLoadCallback, which is actually a FileParser() implemented as GDScript
# The returns of callback is [img_filename, img, xml_filenames, xml_buffers], which is also
# implemented in getFile

var files_read_callback = JavaScriptBridge.create_callback(project_files_load_from_web)
var xml_files_read_callback = JavaScriptBridge.create_callback(xml_files_load_from_web)

func _ready():
	if OS.get_name() == "Web":
		var window = JavaScriptBridge.get_interface("window")
		window.getProjectFiles(files_read_callback)
		window.getXMLFiles(xml_files_read_callback)
		window.onload()
		

func project_files_load_from_paths(paths):
	print("Data load from path")
	var xml_filepaths = Util.get_xml_paths(paths)
	var img_filepath = Util.get_img_path(paths)
	
	var img_filename = img_filepath.get_file()
	var xml_filenames = []
	var xml_strs = []
	var img
	
	for xml_filepath in xml_filepaths:
		xml_filenames.push_back(xml_filepath.get_file())
		var xml_str = FileAccess.get_file_as_string(xml_filepath).to_utf8_buffer()
		xml_strs.push_back(xml_str)
		
	img = Image.new()
	var err = img.load(img_filepath)
	
	if err != OK:
		print("image loading error!")
		
	project_files_opened.emit([img_filename, img, xml_filenames.size(), xml_filenames, xml_strs])
		

func project_files_load_from_web(args):
	# args = [image_filename, image(base64str), num_xml, xml_filenames, xml_strs]
	if args.size() < 1:
		print("Error!")
	
	var img_filename = args[0]

	var img_base64_str = args[1].replace("data:image/png;base64,", "")
	var img_byte_buffer = Marshalls.base64_to_raw(img_base64_str)
	var img = Image.new()
	img.load_png_from_buffer(img_byte_buffer)

	var num_xml = args[2]
	var xml_filenames = args[3]
	var xml_strs = args[4]

	project_files_opened.emit([img_filename, img, num_xml, xml_filenames, xml_strs])


func xml_files_load_from_web(args):
	# args = [num_xml, xml_filenames, xml_strs]
	var num_xml = args[0]
	var xml_filenames = args[1]
	var xml_strs = args[2]

	xml_files_opened.emit([num_xml, xml_filenames, xml_strs])
	
	
func xml_files_load_from_paths(paths):
	var xml_filepaths = Util.get_xml_paths(paths)
	
	var xml_filenames = []
	var xml_buffers = []
	
	for xml_filepath in xml_filepaths:
		xml_filenames.push_back(xml_filepath.get_file())
		var xml_buffer = FileAccess.get_file_as_string(xml_filepath).to_utf8_buffer()
		xml_buffers.push_back(xml_buffer)
		
	xml_files_opened.emit([xml_filenames.size(), xml_filenames, xml_buffers])
	

func parse_symbol_type_to_dict(symbol_type_str: String):
	var symbol_type_set = {}
	var lines = symbol_type_str.split("\n")
	for line in lines:
		var strs = line.split("|")
		if strs[0].is_empty():
			continue
		
		if !symbol_type_set.has(strs[0]):
			symbol_type_set[strs[0]] = [strs[1]]
		else:
			symbol_type_set[strs[0]].append(strs[1])
			
	if !symbol_type_set.has(Config.TEXT_TYPE_NAME):
		symbol_type_set[Config.TEXT_TYPE_NAME] = []
		
	if !symbol_type_set.has("None"):
		symbol_type_set["None"] = ["None"]
		
	return symbol_type_set
