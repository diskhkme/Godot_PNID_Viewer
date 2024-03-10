# Image scene
# display image as texture

extends Node2D
class_name ImageScene

func init_texture(target_project: Project) -> Vector2:
	var texture = ImageTexture.create_from_image(target_project.img)
	$PNIDImage.texture = texture
	
	global_position = texture.get_size()*0.5
	
	return Vector2(texture.get_width(), texture.get_height())
	





