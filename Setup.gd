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
	elif event.is_action_released("take_screenshot"):
		var image = get_viewport().get_texture().get_image()
		image.save_png("user://newton-fractal-screenshot.png")
		var path = ProjectSettings.globalize_path("user://newton-fractal-screenshot.png")
		OS.shell_show_in_file_manager(path)
	elif event.is_pressed() and event is InputEventMouseButton:
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
				root.connect("root_deleted", _on_root_deleted)
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

func _on_root_deleted(root: Node2D):
	$Roots.remove_child(root)
	root.queue_free()
	update_roots()
	update_root_colors()
