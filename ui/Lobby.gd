extends Control

onready var address: LineEdit = $Darken/Center/HBox/VBox/Address
onready var buttons = $Darken/Center/HBox/VBox/buttons
onready var status_ok = $Darken/Center/HBox/VBox/StatusOK
onready var status_fail = $Darken/Center/HBox/VBox/StatusFail


func toggle(onoff) -> void:
	visible = onoff


func _ready():
	PacketHandler.connect("set_back_button", $Darken/Center/HBox/VBox/backbutton, "set_disabled")
	PacketHandler.connect("set_status", self, "_set_status")
	PacketHandler.connect("set_buttons", self, "_set_buttons")
	PacketHandler.connect("set_visible", self, "toggle")
	_set_status(PacketHandler.status[0], PacketHandler.status[1])
	if !Utils.internet_available():
		_set_status("no internet", false)
		_set_buttons(false)
	else:
		_set_buttons(PacketHandler.status[2])


func _set_status(text, isok) -> void:  # Simple way to show status.
	if isok:
		status_ok.set_text(text)
		status_fail.set_text("")
	else:
		status_ok.set_text("")
		status_fail.set_text(text)
	status_ok.visible = len(status_ok.text) > 0
	status_fail.visible = len(status_fail.text) > 0


func _set_buttons(enabled = true) -> void:
	for c in buttons.get_children():
		c.disabled = !enabled
	address.editable = enabled


func _on_join_pressed() -> void:
	validate_text()
	PacketHandler.requestjoin()


func _on_HostButton_pressed() -> void:
	validate_text()
	PacketHandler.requesthost()


func validate_text(text = address.get_text()) -> String:
	var pos = address.caret_position
	text = text.strip_edges()
	text = text.replace(" ", "_")
	address.text = text
	address.caret_position = pos
	Globals.network.game_code = text
	return text


func _on_Address_text_entered(new_text: String):
	validate_text(new_text)


func _on_backbutton_pressed():
	PacketHandler.return()
	get_tree().change_scene("res://ui/StartMenu.tscn")
