# Image scene
# display image as texture

extends Node2D
class_name ImageScene

var img_texture_dict = {}

func set_texture(image: Image):
	var texture
	if img_texture_dict.has(image):
		texture = img_texture_dict[image]
	else:
		texture = ImageTexture.create_from_image(image)
	
	$PNIDImage.texture = texture
	global_position = texture.get_size()*0.5	
	
	
	
