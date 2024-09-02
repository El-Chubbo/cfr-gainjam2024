extends VBoxContainer

@onready var mov_label = $MovNum
@onready var ap_label = $APNum

func _ready() -> void:
	ap_label.text = ("AP: ") + str(PlayerData.current_data["MaxActionPoints"])
	mov_label.text = ("MOV: ") + str(PlayerData.current_data["MaxMovement"])
	return

func _on_AP_update(current_AP : int) -> void:
	ap_label.text = ("AP: ") + str(current_AP)
	if current_AP == PlayerData.current_data["MaxActionPoints"]:
		ap_label.label_settings.font_color = Color.GREEN
	else:
		ap_label.label_settings.font_color = Color.WHITE

func _on_MOV_update(current_MOV : int) -> void:
	mov_label.text = ("MOV: ") + str(current_MOV)
	if current_MOV == PlayerData.current_data["MaxMovement"]:
		mov_label.label_settings.font_color = Color.GREEN
	elif current_MOV == 0:
		mov_label.label_settings.font_color = Color.RED
		return
	else:
		mov_label.label_settings.font_color = Color.WHITE
