extends AnimatableBody2D

@export var left_movement : float = 256
var left_goal : Vector2

@export var right_movement : float = 256
var right_goal : Vector2

@export var movement_speed : float = 20
var current_speed

@export var current_direction : = Vector2.RIGHT
@export var terminal_delay : float = 2

@export var acceptable_error : float = 0.05

var total_distance = left_movement + right_movement

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	left_goal = self.global_position
	left_goal.x -= left_movement
	
	right_goal = self.global_position
	right_goal.x += right_movement

	current_speed = movement_speed
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	
	var motion = current_direction.x * delta * current_speed
	self.move_local_x(motion)
	
	if has_reached_goal() or close_enough_to_goal():
		current_speed = 0
		current_direction *= -1
		await get_tree().create_timer(terminal_delay).timeout
		current_speed = movement_speed
		
	
func has_reached_goal():
	if current_direction == Vector2.RIGHT:
		return self.global_position.x >= right_goal.x
	else:
		return self.global_position.x <= left_goal.x
	
func close_enough_to_goal():
	##print(self.global_position.distance_to(right_goal))
	return current_direction == Vector2.RIGHT and self.global_position.distance_to(right_goal) <= acceptable_error or current_direction == Vector2.LEFT and self.global_position.distance_to(left_goal) <= acceptable_error
