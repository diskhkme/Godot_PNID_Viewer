extends Node
class_name Diff

# TODO: rotated bbox iou calculation

static func calculate_diff(first: Array[SymbolObject], second: Array[SymbolObject], options: Variant) -> Array[SymbolObject]:
	var iou_th: float = options[0]
	var include_symbol: bool = options[1]
	var include_text: bool = options[2]
	var compare_string: bool = options[3]
	var compare_degree: bool = options[4]
	
	# remove not included
	first = filter_by_type(first, include_symbol, include_text)
	second = filter_by_type(second, include_symbol, include_text)
	
	var diffs: Array[SymbolObject] = []
	var first_filtered = filter_by_iou_string_degree(first, second, iou_th, compare_string, compare_degree)
	diffs.append_array(first_filtered)
	var second_filtered = filter_by_iou_string_degree(second, first, iou_th, compare_string, compare_degree)
	diffs.append_array(second_filtered)

	# TODO: how to handle id? (for selection)
	return diffs


static func filter_by_type(symbol_array: Array[SymbolObject], include_symbol: bool, include_text: bool):
	if !include_symbol:
		symbol_array = symbol_array.filter(func(a): return !a.is_text)
	if !include_text:
		symbol_array = symbol_array.filter(func(a): return a.is_text)
	return symbol_array
	

static func filter_by_iou_string_degree(first, second, iou_th, compare_string, compare_degree):
	var filtered = []
	for f in first:
		var candidate = second.filter(func(s): return check_iou_cond(f, s, iou_th))
		
		if candidate.size() == 0: # if no iou cond meet, store f
			filtered.push_back(f)
			continue
		else: # check remaining condition
			if compare_string and f.is_text:
				candidate = candidate.filter(func(s): return f.cls == s.cls)
			if compare_degree:
				# TODO: parameterize degree threshold?
				candidate = candidate.filter(func(s): return abs(f.degree - s.degree) < 4)
				
		if candidate.size() == 0: # if no cond meet, store f
			filtered.push_back(f)
			
	return filtered


static func check_iou_cond(a: SymbolObject, b: SymbolObject, iou_th:float) -> bool:
	return iou_calc(a.get_rotated_bndbox(), b.get_rotated_bndbox()) > iou_th
	

static func iou_calc(box1: Vector4, box2: Vector4):
	var x_inter_min = max(box1[0], box2[0])
	var y_inter_min = max(box1[1], box2[1])
	var x_inter_max = min(box1[2], box2[2])
	var y_inter_max = min(box1[3], box2[3])

	var inter_width = max(0, x_inter_max - x_inter_min)
	var inter_height = max(0, y_inter_max - y_inter_min)

	var intersection_area = inter_width * inter_height

	var box1_area = (box1[2] - box1[0]) * (box1[3] - box1[1])
	var box2_area = (box2[2] - box2[0]) * (box2[3] - box2[1])

	var union_area = box1_area + box2_area - intersection_area

	var iou = intersection_area / union_area if union_area != 0 else 0

	return iou
