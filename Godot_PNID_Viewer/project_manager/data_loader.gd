extends Node

signal file_opened(args: Variant)

var webFileLoadCallback = JavaScriptBridge.create_callback(data_load_from_web)

# In web build, callback of getFile(implemented in "header include" of build setting) is
# designated to webFileLoadCallback, which is actually a FileParser() implemented as GDScript
# The returns of callback is [img_filename, img, xml_filenames, xml_buffers], which is also
# implemented in getFile

var buffer

func _ready():
	if OS.get_name() == "Web":
		var window = JavaScriptBridge.get_interface("window")
		window.getFile(webFileLoadCallback)
		
		
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
		var xml_buffer = FileAccess.get_file_as_bytes(xml_filepath)
		xml_buffers.push_back(xml_buffer)
		
	img = Image.new()
	var err = img.load(img_filepath)
	
	if err != OK:
		print("image loading error!")
		
	return [img_filename, img, xml_filenames, xml_buffers]


func data_load_from_web(args):
	var console = JavaScriptBridge.get_interface("console")
	console.log("Data load from web")
	# TODO: xml file이 두 개 이상이때 JS 배열을 Godot로 가져오는 데 문제가 있어서 해결해야 함
	# TODO: image file 형식이 호환되지 않으므로 byte로 읽어와서 다시 decoding해서 사용해야 함
	console.log(args[1])
	args[2] = [args[2]]
	args[3] = [args[3]]
	file_opened.emit(args)
	
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(_http_request_completed)

	# Perform the HTTP request. The URL below returns a PNG image as of writing.
	var error = http_request.request(args[1])
	if error != OK:
		push_error("An error occurred in the HTTP request.")
	
	console.log("Success?")

func get_buffer_from_web():
	return buffer
	
	
# Called when the HTTP request is completed.
func _http_request_completed(result, response_code, headers, body):
	var image = Image.new()
	var error = image.load_png_from_buffer(body)
	if error != OK:
		push_error("Couldn't load the image.")

	var texture = ImageTexture.new()
	texture.create_from_image(image)
	

#func FileParser(args): 
	#var console = JavaScriptBridge.get_interface("console")
	#console.log(args[0]) # image file
	#console.log(args[1]) # xml files
	
	
