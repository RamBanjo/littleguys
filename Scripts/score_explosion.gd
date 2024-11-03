extends Node2D

var score = 50
var guy_count = 1
var up_speed = 20

@onready var text_label = $RichTextLabel
@onready var my_timer = $Timer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	self.position.y -= delta * up_speed
	self.modulate.a = my_timer.time_left / my_timer.wait_time

func set_score_text():
	
	var  new_text = ""
	
	if guy_count <= 3:
		new_text = "[outline_size=3][outline_color=#000000][center]{score}x{guy_count}[/center][/outline_color][/outline_size]"
	
	elif guy_count <= 7:
		score = 75
		text_label.add_theme_font_size_override("normal_font_size", 32)
		new_text = "[shake rate=20.0 level=20 connected=1][outline_size=3][outline_color=#000000][center]{score}x{guy_count}[/center][/outline_color][/outline_size][/shake]"
		
	else:
		score = 100
		text_label.add_theme_font_size_override("normal_font_size", 64)
		new_text = "[shake rate=20.0 level=20 connected=1][rainbow freq=1.0 sat=0.8 val=0.8][outline_size=3][outline_color=#000000][center]{score}x{guy_count}[/center][/outline_color][/outline_size][/rainbow][/shake]"
	
	text_label.text = new_text.format({"score":score, "guy_count":guy_count})

func _on_timer_timeout() -> void:
	queue_free()
