extends Control

@onready var version_label : Label = %VersionLabel

func _ready() -> void:
	version_label.text = "Version: " + ProjectSettings.get_setting("application/config/version")
	return
