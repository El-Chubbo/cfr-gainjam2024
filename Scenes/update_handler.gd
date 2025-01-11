extends Node2D

var url = "https://itch.io/api/1/x/wharf/latest?game_id=2932531&channel_name=windows"
var backup_url = "https://itch.io/api/1/x/wharf/latest?game_id=2932531&channel_name=html"

@onready var http_request = %UpdateChecker

func _ready() -> void:
	if OS.has_feature("web"):
		http_request.queue_free()
		queue_free()
		return
	http_request.request_completed.connect(_on_request_completed)
	send_request()
	return

func send_request():
	print("Checking for updates...")
	var headers = ["Content-Type: application/json"]
	http_request.request(url,headers,HTTPClient.METHOD_GET)
	return

func _on_request_completed(results, response_code, headers, body):
	var json = JSON.parse_string(body.get_string_from_utf8())
	print(json)
	print("HTTP Request: Current version is ", json["latest"])
	return
