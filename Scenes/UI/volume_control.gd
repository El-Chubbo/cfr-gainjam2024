extends Control

var music_bus = AudioServer.get_bus_index("Music")

func _on_h_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(music_bus, linear_to_db(value))
	return

func _ready() -> void:
	$HSlider.value = db_to_linear(AudioServer.get_bus_volume_db(music_bus))
