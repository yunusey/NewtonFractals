extends Node2D

var root_scene: PackedScene = preload("res://Root/Root.tscn")
var is_dragging: bool = false

func update_roots() -> void:
	var new_roots = PackedVector2Array()
	for root in $Roots.get_children():
		var real_position = Vector2(root.position.x, -root.position.y) / 108.0 + Vector2(-5.0, 5.0)
		new_roots.append(real_position)
	$Fractal.change_roots(new_roots)

func update_root_colors() -> void:
	var root_colors = PackedColorArray()
	for root in $Roots.get_children():
		root_colors.append(root.color)
	$Fractal.change_root_colors(root_colors)

func _process(_delta):
	if is_dragging:
		update_roots()
		update_root_colors()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("begin_animation"):
		$Fractal.animation_running = true
		$NumberLine.hide()
		$Roots.hide()
	
	if event.is_pressed() and event is InputEventMouseButton:
		match event.button_index:
			MOUSE_BUTTON_RIGHT:
				if $Fractal.animation_running:
					return
				var mouse_position = get_global_mouse_position()
				var root = root_scene.instantiate()
				root.position = mouse_position
				root.color = Color(randf(), randf(), randf())
				root.connect("color_changed", _on_root_color_changed)
				root.connect("drag_started", _on_root_drag_started)
				root.connect("drag_ended", _on_root_drag_ended)
				$Roots.add_child(root)
				update_roots()
				update_root_colors()
			MOUSE_BUTTON_WHEEL_DOWN:
				$Fractal.decrease_iterations()
			MOUSE_BUTTON_WHEEL_UP:
				$Fractal.increase_iterations()

func _on_root_color_changed():
	update_root_colors()

func _on_root_drag_started():
	is_dragging = true

func _on_root_drag_ended():
	is_dragging = false
