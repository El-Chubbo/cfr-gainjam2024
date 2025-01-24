extends Node2D

var url = "https://itch.io/api/1/x/wharf/latest?game_id=2932531&channel_name=windows"
var remote_version : String = ""
@onready var current_version = ProjectSettings.get_setting("application/config/version")
@onready var http_request = %UpdateChecker
@export var check_for_updates : bool = true

func _ready() -> void:
	if OS.has_feature("web") or not check_for_updates:
		http_request.queue_free()
		queue_free()
		return
	http_request.request_completed.connect(_on_request_completed)
	send_request()

func send_request():
	print("Checking for updates...")
	var headers = ["Content-Type: application/json"]
	http_request.request(url,headers,HTTPClient.METHOD_GET)
	return

func _on_request_completed(results, response_code, headers, body):
	var json = JSON.parse_string(body.get_string_from_utf8())
	if !json:
		print("Failed to get remote version")
		%VersionLabel.text = current_version + ", failed to check for update"
		return
	print("HTTP Request: Remote version is ", json["latest"])
	remote_version = json["latest"]
	if remote_version == "": # probably should have a more refined error handler
		print("Failed to get remote version")
	else:
		notify_update()
	return

func notify_update() -> void:
	var version_difference : int = compare_versions()
	match version_difference:
		0:
			# versions are identical
			print("Installed version ", current_version, " is up to date with remote version")
			pass
		1:
			# current version is ahead remote
			print("Installed version ", current_version, " is newer than remote version")
			pass
		-1:
			# current version is behind remote, tell user to update!
			print("Installed version ", current_version, " is older than remote version")
			%VersionLabel.show_update(remote_version)
			pass
		_:
			# the format of versions don't match, can't determine which is newer
			print("Installed version ", current_version, " string format does not match remote!")
			pass
	return

func compare_versions() -> int:
	if remote_version == current_version:
		return 0
	var remote_values : PackedStringArray = remote_version.split(".", true, 3)
	var local_values : PackedStringArray = current_version.split(".", true, 3)
	# split the x.y.z versioning string into an array of strings ["x","y","z"]
	# then compare the integer values
	if remote_values.size() != local_values.size():
		return -2
	for i in range(3):
		if remote_values[i].to_int() == local_values[i].to_int():
			continue
		if remote_values[i].to_int() > local_values[i].to_int():
			return -1
		if remote_values[i].to_int() < local_values[i].to_int():
			return 1
	return 0
	# if for whatever reason I stop using the x.y.z formatting, this check breaks
