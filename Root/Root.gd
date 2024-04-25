extends Area2D

signal color_changed
signal drag_started
signal drag_ended
signal root_deleted(Node2D)

@export_color_no_alpha var color = Color(1.0, 0.0, 0.0)
var is_dragging = false
var is_hovering = false

func _ready():
	$MeshInstance2D.material.set_shader_parameter("color", color)

func _process(_delta):
	if is_dragging:
		global_position = get_global_mouse_position()

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			is_dragging = true
			emit_signal("drag_started")
		else:
			is_dragging = false
			emit_signal("drag_ended")

func _on_mouse_entered():
	is_hovering = true

func _on_mouse_exited():
	is_hovering = false

func _input(event: InputEvent):
	if event is InputEventKey and event.keycode == KEY_A and is_hovering:
		$ColorPicker.show()
	if event is InputEventKey and event.keycode == KEY_ESCAPE and $ColorPicker.visible:
		$ColorPicker.hide()
	if event is InputEventKey and event.keycode == KEY_X and is_hovering:
		emit_signal("root_deleted", self)

func _on_color_picker_color_changed(new_color: Color):
	$MeshInstance2D.material.set_shader_parameter("color", new_color)
	self.color = new_color
	emit_signal("color_changed")

func _on_color_picker_mouse_exited():
	$ColorPicker.hide()
