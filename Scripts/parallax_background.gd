extends ParallaxBackground

@export var x_scroll : float = 0
@export var y_scroll : float = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	scroll_offset.x -= x_scroll * delta
	scroll_offset.y += y_scroll * delta
