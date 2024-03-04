extends Control

@export var xml_container: PackedScene = preload("res://ui/xml_container.tscn")

@onready var xml_container_parent = $ScrollContainer


func use_project(project: Project) -> void:
	var prev = null
	for xml_stat in project.xml_status:
		var xml_container_instance = xml_container.instantiate() as XMLContainer
		xml_container_parent.add_child(xml_container_instance)
		xml_container_instance.initialize(xml_stat)
		
		
