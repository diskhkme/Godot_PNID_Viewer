class_name Util

static var timers = {}
static var is_debug: bool = true

static func get_img_path(paths) -> String:
	for path in paths:
		for img_format in Config.ALLOW_IMG_FORMAT:
			if path.contains(img_format): # cannot open jpeg, currently
				return path
			
	return String()
			

static func get_valid_data_paths(paths) -> PackedStringArray:
	var xml_paths = PackedStringArray()
	var valid_extionsion = Config.ALLOW_DATA_FORMAT.values()
	for path in paths:
		for data_format in valid_extionsion:
			if path.contains(data_format): 
				xml_paths.append(path)
				break
			
	return xml_paths
	
	
static func get_img_file_filter() -> String:
	var str = ""
	for img_format in Config.ALLOW_IMG_FORMAT:
		str += "*" + img_format + ", "
	
	str = str.left(str.length()-2)
	return str
	
	
static func get_data_file_filter() -> String:
	var str = ""
	var extentions: Array[String]
	extentions.assign(unique_array(Config.ALLOW_DATA_FORMAT.values()))
	for data_format in extentions:
		str += "*" + data_format + ", "
	str = str.left(str.length()-2)
	return str


static func log_start(log_name: String):
	timers[log_name] = Time.get_ticks_msec()
	
	
static func log_end(log_name: String):
	var time = Time.get_ticks_msec() - timers[log_name]
	if is_debug:
		print(log_name, " %d ms" % time)


static func debug_msg(msg):
	if is_debug:
		print(msg)

static func unique_array(arr: Array) -> Array:
	var dict := {}
	for a in arr:
		dict[a] = 1
	return dict.keys()
