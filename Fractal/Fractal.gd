extends Node2D

const MAX_ITERATIONS: int = 100
@export_range(0.0001, 10000.0, 0.001) var newton_scale: float = 1.0
@export_range(1, MAX_ITERATIONS, 1) var num_iterations: int = 20
var animation_running: bool = false

func _ready() -> void:
	self.material.set_shader_parameter("scale", self.newton_scale)
	self.material.set_shader_parameter("num_iterations", self.num_iterations)
	self.animation_running = false

func _process(_delta) -> void:
	if self.animation_running:
		self.newton_scale *= 1.001
		self.material.set_shader_parameter("scale", self.newton_scale)

func change_roots(new_roots: PackedVector2Array) -> void:
	self.material.set_shader_parameter("num_roots", new_roots.size())
	self.material.set_shader_parameter("roots", new_roots)

func change_root_colors(new_root_colors: PackedColorArray) -> void:
	self.material.set_shader_parameter("root_colors", new_root_colors)

func increase_iterations() -> void:
	self.num_iterations = clamp(self.num_iterations + 1, 1, MAX_ITERATIONS)
	self.material.set_shader_parameter("num_iterations", self.num_iterations)

func decrease_iterations() -> void:
	self.num_iterations = clamp(self.num_iterations - 1, 1, MAX_ITERATIONS)
	self.material.set_shader_parameter("num_iterations", self.num_iterations)
