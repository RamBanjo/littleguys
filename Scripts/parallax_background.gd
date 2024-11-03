extends ParallaxBackground

@export var x_scroll : float = 0
var current_x_scroll = x_scroll
@export var y_scroll : float = 0
var current_y_scroll = y_scroll

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_background_settings()
	pass # Replace with function body.


func update_background_settings():
	
	match Options.background_scroll:
		
		Options.BackgroundOption.SCROLLING:
			current_x_scroll = x_scroll
			current_y_scroll = y_scroll
			self.show()
		
		Options.BackgroundOption.STATIC:
			current_x_scroll = 0
			current_y_scroll = 0
			
			scroll_offset = Vector2.ZERO
			self.show()
		
		Options.BackgroundOption.EMPTY:
			self.hide()
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	scroll_offset.x -= current_x_scroll * delta
	scroll_offset.y += current_y_scroll * delta
