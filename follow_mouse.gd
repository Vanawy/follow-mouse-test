extends CharacterBody2D

@export var area: Area2D
@export var offset_node: Node2D
@export var speed_label: Label
@export var decay_toggle: CheckButton
@export var decay_val: LineEdit
@export var speed_val: LineEdit
@export var events: TextEdit

var offset: Vector2 = Vector2.ZERO
var is_dragging: bool = false

@export_category("Params")
@export var use_decay = true
var max_speed: float = 400

const DECAY_LIMIT: int = 25
@export_range(1, DECAY_LIMIT) var decay: int = 10

var prev_pos: Vector2 = Vector2.ZERO


func init_ui() -> void:
	decay_toggle.button_pressed = use_decay
	decay_toggle.toggled.emit(use_decay)
	decay_toggle.toggled.connect(func(v: bool):
		use_decay = v
		decay_val.editable = v
	)
	decay_val.text = str(decay)
	decay_val.text_changed.connect(func(new_text: String):
		var new_val := new_text.to_int()
		if new_val > 0:
			decay = new_val
		else:
			decay_val.text = str(decay)
	)
	speed_val.text = str(max_speed)
	speed_val.text_changed.connect(func(new_text: String):
		var new_val := new_text.to_int()
		if new_val > 0:
			max_speed = new_val
		else:
			speed_val.text = str(max_speed)
	)


func _ready() -> void:
	
	init_ui()
	
	area.input_event.connect(func (_view: Viewport, event: InputEvent, _shape_id: int):
		if event.is_pressed():
			start_drag()
	)

func exp_decay(a: Vector2, b: Vector2, decay: float, delta: float) -> Vector2:
	return b + (a - b) * exp(-decay * delta)


func _physics_process(delta: float) -> void:
	
	offset_node.position = offset
	
	var actual_diff: Vector2
	if use_decay:
		actual_diff = exp_decay(Vector2.ZERO, offset, decay, delta).limit_length(max_speed * delta)
	else:
		actual_diff = offset.limit_length(max_speed * delta)
	offset -= actual_diff
	global_position += actual_diff
	
	speed_label.text = str(roundf((position - prev_pos).length() * (1 / delta) * 100) / 100)
	prev_pos = position

func start_drag() -> void:
	is_dragging = true
	offset = Vector2.ZERO
	
func stop_drag() -> void:
	is_dragging = false

func _unhandled_input(event: InputEvent) -> void:
	
	if event is InputEventMouseButton:
		var btn := event as InputEventMouseButton
		if is_dragging and btn.is_released():
			stop_drag()
			events.text += "Mouse btn released\n"
	if event is InputEventScreenTouch:
		var touch := event as InputEventMouseButton
		if is_dragging and touch.is_released():
			stop_drag()
			events.text += "Touch released\n"
			
		
		
	if event is InputEventMouseMotion:
		var drag := event as InputEventMouseMotion
		if is_dragging:
			offset += drag.screen_relative
			events.text += "Mouse: " + str(drag.screen_relative) + "\n"
			
	if event is InputEventScreenDrag:
		var drag := event as InputEventScreenDrag
		if is_dragging:
			offset += drag.screen_relative
			events.text += "Drag: " + str(drag.screen_relative) + "\n"
			
	
	if randf() < 0.1:
		if events.text.length() > 500:
			events.text = events.text.erase(0, events.text.length() - 500)
			
	events.scroll_vertical = 1000
