extends Control

@export var viewport_container: SubViewportContainer
@export var viewport: SubViewport


func take_screenshot():
	var scene_status = save_scene_status()
	var export_img = await get_screenshot_image()
	load_scene_status(scene_status)
	
	return export_img
	

func save_scene_status():
	var previous_size = viewport.size
	var previous_cam_pos = viewport.get_camera_2d().global_position
	var previous_cam_zoom = viewport.get_camera_2d().zoom
	viewport_container.stretch = false
	
	return [previous_size, previous_cam_pos, previous_cam_zoom]
	

# TODO: Visualize coroutine awaiting
func get_screenshot_image():
	var target_size = ProjectManager.active_project.img.get_size()
	viewport.size = target_size
	viewport.get_camera_2d().global_position = target_size/2
	viewport.get_camera_2d().zoom = Vector2.ONE
	
	await RenderingServer.frame_post_draw
	var export_img = viewport.get_texture().get_image()
	
	return export_img
	

func load_scene_status(scene_status):
	viewport.size = scene_status[0]
	viewport_container.stretch = true
	viewport.get_camera_2d().global_position = scene_status[1]
	viewport.get_camera_2d().zoom = scene_status[2]
