extends Node

signal file_opened(args: Variant)

var file_read_callback = JavaScriptBridge.create_callback(data_load_from_web)

# In web build, callback of getFile(implemented in "header include" of build setting) is
# designated to webFileLoadCallback, which is actually a FileParser() implemented as GDScript
# The returns of callback is [img_filename, img, xml_filenames, xml_buffers], which is also
# implemented in getFile



var buffer

var console = JavaScriptBridge.get_interface("console")

func _ready():
	if OS.get_name() == "Web":
		var window = JavaScriptBridge.get_interface("window")
		window.getFile(file_read_callback)
		window.onload()
		
		
func data_load_from_paths(paths):
	print("Data load from path")
	var xml_filepaths = Util.get_xml_paths(paths)
	var img_filepath = Util.get_img_path(paths)
	
	var img_filename = img_filepath.get_file()
	var xml_filenames = []
	var xml_buffers = []
	var img
	
	for xml_filepath in xml_filepaths:
		xml_filenames.push_back(xml_filepath.get_file())
		var xml_buffer = FileAccess.get_file_as_string(xml_filepath)
		xml_buffers.push_back(xml_buffer)
		
	img = Image.new()
	var err = img.load(img_filepath)
	
	if err != OK:
		print("image loading error!")
		
	return [img_filename, img, xml_filenames.size(), xml_filenames, xml_buffers]


func data_load_from_web(args):
	# image_filename, image(base64str), num_xml, xml_filenames, xml_strs
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

	file_opened.emit([img_filename, img, num_xml, xml_filenames, xml_strs])


# TODO: Need to refer definitions from external file. (couldn't resolve the CORS problem in case of the web)
#func symboltype_load_from_web(symbol_type_str: String):
	#console.log(symbol_type_str)
	#return parse_symbol_type_to_dict(symbol_type_str)
	#
#
#func symboltype_load_from_path(symbol_type_path: String):
	#var symboltype_buffer = FileAccess.get_file_as_string(symbol_type_path)
	#return parse_symbol_type_to_dict(symboltype_buffer)
	
	
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
