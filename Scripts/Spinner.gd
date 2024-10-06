extends AnimatableBody2D

enum SpinDirection{
	CW, CCW
}

enum SpinnerLength{
	SHORT, LONG
}

var spinner_sprite = {
	SpinDirection.CW: {SpinnerLength.SHORT: preload("res://Sprites/StageParts/spinner_bar.png"), SpinnerLength.LONG: preload("res://Sprites/StageParts/spinner_long.png")},
	SpinDirection.CCW: {SpinnerLength.SHORT: preload("res://Sprites/StageParts/anticcw_spinner.png"), SpinnerLength.LONG: preload("res://Sprites/StageParts/anticcw_spinner_long.png")}
}

@onready var my_sprite = $Sprite2D

@export var spin_direction : SpinDirection = SpinDirection.CW
@export var spinner_length: SpinnerLength = SpinnerLength.SHORT
@export var spin_speed :float = 40.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	my_sprite.texture = spinner_sprite[spin_direction][spinner_length]
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	
	var multiplier = 1
	
	if spin_direction == SpinDirection.CCW:
		multiplier = -1
	
	self.rotate(spin_speed * multiplier * delta)
