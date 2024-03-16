extends HBoxContainer

@export var add_xml_dialog: FileDialog
@export var export_img_viewport: SubViewport
@export var export_img_viewport_container: SubViewportContainer
@export var save_img_dialog: FileDialog

func _ready():
	if OS.get_name() == "Windows":
		# for windows, start new project if dialog closed
		add_xml_dialog.files_selected.connect(_on_xml_files_selected)
		save_img_dialog.file_selected.connect(_on_save_image_file)
	if OS.get_name() == "Web":
		# for web, start new project if dataloader signaled
		DataLoader.xml_files_opened.connect(_add_xml_to_project)


func _on_add_xml_button_pressed():
	if OS.get_name() == "Windows":
		add_xml_dialog.popup()
	elif OS.get_name() == "Web":
		var window = JavaScriptBridge.get_interface("window")
		window.input_xml.click()


func _on_xml_files_selected(paths):
	var args = DataLoader.xml_files_load_from_paths(paths)
	_add_xml_to_project(args)
	
	
func _add_xml_to_project(args):
	var num_xml = args[0]
	var xml_filenames = args[1]
	var xml_str = args[2]
	
	ProjectManager.active_project.add_xml_from_file(num_xml, xml_filenames, xml_str)


func _on_export_image_button_pressed():
	if OS.get_name() == "Windows":
		save_img_dialog.popup()
	if OS.get_name() == "Web":
		var export_img = await take_screenshot()
		var data = export_img.save_png_to_buffer()
		JavaScriptBridge.download_buffer(data, "Screenshot.png", "image/png")

	
func _on_save_image_file(path):
	# TODO: separate exporing module with more options?
	var export_img = await take_screenshot()
	if !path.contains(".png"):
		path += ".png"
	export_img.save_png(path)
		
		
func take_screenshot():
	var scene_status = save_scene_status()
	var export_img = await get_screenshot_image()
	load_scene_status(scene_status)
	
	return export_img
	
func save_scene_status():
	var previous_size = export_img_viewport.size
	var previous_cam_pos = export_img_viewport.get_camera_2d().global_position
	var previous_cam_zoom = export_img_viewport.get_camera_2d().zoom
	export_img_viewport_container.stretch = false
	
	return [previous_size, previous_cam_pos, previous_cam_zoom]
	

# TODO: Visualize coroutine awaiting
func get_screenshot_image():
	var target_size = ProjectManager.active_project.img.get_size()
	export_img_viewport.size = target_size
	export_img_viewport.get_camera_2d().global_position = target_size/2
	export_img_viewport.get_camera_2d().zoom = Vector2.ONE
	
	await RenderingServer.frame_post_draw
	var export_img = export_img_viewport.get_texture().get_image()
	
	return export_img
	

func load_scene_status(scene_status):
	export_img_viewport.size = scene_status[0]
	export_img_viewport_container.stretch = true
	export_img_viewport.get_camera_2d().global_position = scene_status[1]
	export_img_viewport.get_camera_2d().zoom = scene_status[2]
