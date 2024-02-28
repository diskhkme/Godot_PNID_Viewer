extends Node


func ready():
	get_tree().call_group("symbol", "test")
	
	
func test():
	print("test")
