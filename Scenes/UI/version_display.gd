extends Control

@onready var link : LinkButton = %LinkButton

func _ready() -> void:
	self.text = "Version: " + ProjectSettings.get_setting("application/config/version")
	
	return

func show_update(new_version : String = "") -> void:
	link.text = "New update available: version " + new_version
	link.visible = true
	return
