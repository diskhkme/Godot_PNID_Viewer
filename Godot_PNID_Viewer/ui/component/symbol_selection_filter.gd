# Symbol scene select filter
# return single symbol from multiple candidates, or null if deselect


extends Node
class_name SymbolSelectionFilter

var last_selected_candidate: Array[StaticSymbolDisplay]
var selected_history = {} # false if excluded from candidate

func update_history(selected_candidate: Array[StaticSymbolDisplay]):
	var new_history = {}
	for sel in selected_candidate:
		if sel in selected_history:
			new_history[sel] = selected_history[sel]
		else:
			new_history[sel] = true
	selected_history = new_history


func reset_history(selected_candidate: Array[StaticSymbolDisplay]):
	selected_history.clear()
	for sel in selected_candidate:
		selected_history[sel] = true
		
		
func is_same_array(arr1, arr2):
	if arr1.size() != arr2.size():
		return false
		
	for elem in arr1:
		if !arr2.has(elem):
			return false
			
	return true
		

func decided_selected(selected_candidate: Array[StaticSymbolDisplay]):
	if selected_candidate.size() == 0:
		selected_history.clear()
		last_selected_candidate.clear()
		return null
	
	if selected_candidate.size() == 1: # if single selected
		selected_history.clear()
		last_selected_candidate.clear()
		return selected_candidate[0]
		
	if last_selected_candidate.is_empty(): # if multiple selected first
		reset_history(selected_candidate)
		last_selected_candidate = selected_candidate.duplicate()
		selected_history[selected_candidate[0]] = false
		return selected_candidate[0]
		
	if is_same_array(selected_candidate, last_selected_candidate):
		# if same selected multiple times, simple loop selected
		for sel in selected_candidate:
			if selected_history[sel] == true:
				selected_history[sel] = false
				return sel
				
		#if not found, reset history and return first
		reset_history(selected_candidate)
		selected_history[selected_candidate[0]] = false
		return selected_candidate[0]
	else:
		# if selection changed
		update_history(selected_candidate)
		last_selected_candidate = selected_candidate.duplicate()
		for sel in selected_candidate:
			if selected_history[sel] == true:
				selected_history[sel] = false
				return sel
				
	#if not in case, return null
	selected_history.clear()
	last_selected_candidate.clear()
	return null
		
		
			
			

