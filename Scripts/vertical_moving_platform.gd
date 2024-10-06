extends AnimatableBody2D

@export var up_movement : float = 256
var up_goal

@export var down_movement : float = 256
var down_goal

@export var movement_speed : float = 20
var current_speed

@export var current_direction : = Vector2.UP
@export var terminal_delay : float = 2

@export var acceptable_error : float = 0.05

var total_distance = up_movement + down_movement

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	up_goal = self.global_position
	up_goal.y -= up_movement
	
	down_goal = self.global_position
	down_goal.y += down_movement

	current_speed = movement_speed
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	
	var motion = current_direction.y * delta * current_speed
	self.move_local_y(motion)
	
	if close_enough_to_goal():
		current_speed = 0
		current_direction *= -1
		await get_tree().create_timer(terminal_delay).timeout
		current_speed = movement_speed
		
	

func close_enough_to_goal():
	#print(self.global_position.distance_to(up_goal))
	return current_direction == Vector2.UP and self.global_position.distance_to(up_goal) <= acceptable_error or current_direction == Vector2.DOWN and self.global_position.distance_to(down_goal) <= acceptable_error
