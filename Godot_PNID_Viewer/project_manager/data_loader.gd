extends Node

signal project_files_opened(args: Variant)
signal data_files_opened(args: Variant)

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
		

func img_file_load_from_path(path):
	print("Image load from path")
	var img_filepath = path
	
	var img_filename = img_filepath.get_file()
	var img
	
	img = Image.new()
	var err = img.load(img_filepath)
	
	if err != OK:
		print("image loading error!")
		
	project_files_opened.emit([img_filename, img])
		

func project_files_load_from_web(args):
	# args = [image_filename, image(base64str), num_xml, xml_filenames, xml_strs]
	if args.size() < 1:
		print("Error!")
	
	var img_filename = args[0]
	var meta
	if img_filename.get_extension() == "png":
		meta = "png"
	elif img_filename.get_extension() == "jpg" or img_filename.get_extension() == "jpeg":
		meta = "jpeg"
	
	var img_base64_str = args[1].replace("data:image/%s;base64," % meta, "")
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

	data_files_opened.emit([num_xml, xml_filenames, xml_strs, "XML"])
	
func data_files_load_from_path(paths, format):
	var data_filepaths = Util.get_valid_data_paths(paths)
	
	var data_filenames = []
	var data_buffers = []
	
	for data_filepath in data_filepaths:
		data_filenames.push_back(data_filepath.get_file())
		var data_buffer = FileAccess.get_file_as_string(data_filepath)
		data_buffers.push_back(data_buffer)
		
	data_files_opened.emit([data_filenames.size(), data_filenames, data_buffers, format])
	
func xml_files_load_from_paths(paths):
	data_files_load_from_path(paths, "XML")
	
func dota_files_load_from_paths(paths):
	data_files_load_from_path(paths, "DOTA")
	
func yolo_files_load_from_paths(paths):
	data_files_load_from_path(paths, "YOLO")
	
func coco_files_load_from_paths(paths):
	data_files_load_from_path(paths, "COCO")
	

