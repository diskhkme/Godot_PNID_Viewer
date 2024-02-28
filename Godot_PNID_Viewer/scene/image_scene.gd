# Image scene
# display image as texture

extends Node2D

# image cache
var imgs_dict = {}

func load_image_as_texture(img_filepath: String) -> Vector2:
	var img
	if imgs_dict.has(img_filepath):
		img = imgs_dict[img_filepath]
	else:
		imgs_dict[img_filepath] = Image.new()
		img = imgs_dict[img_filepath]
		var err = img.load(img_filepath)
		if err != OK:
			print("image loading error!")
			
	var texture = ImageTexture.create_from_image(img)
	$PNIDImage.texture = texture
	
	return Vector2(texture.get_width(), texture.get_height())
	





