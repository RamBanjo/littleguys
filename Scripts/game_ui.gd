extends CanvasLayer

var main_menu = "res://Scenes/Menu/MainMenu.tscn"

@onready var score_label = $ScorePanel/ScoreVal
@onready var high_label = $ScorePanel/HighVal
@onready var count_label = $ScorePanel/CountVal
@onready var level_val = $ScorePanel/LevelVal
@onready var time_label = $ScorePanel/TimeVal

@onready var next_preview = [$ScorePanel/LittleGuy, $ScorePanel/LittleGuy2, $ScorePanel/LittleGuy3, $ScorePanel/LittleGuy4, $ScorePanel/LittleGuy5]

@onready var spawn_timer_bar = $ScorePanel/TimeProg
@onready var spawn_timer_label = $ScorePanel/TimeProg/Label

@onready var pause_panel = $PausePanel
@onready var pause_button = $PauseButton

@onready var restart_button = $PausePanel/Restartbutton
@onready var unpause_button = $PausePanel/UnpauseButton
@onready var quit_button = $PausePanel/QuitButton

@onready var game_over_panel = $GameOverPanel
@onready var game_over_score = $GameOverPanel/RichTextLabel
@onready var game_over_gratz = $GameOverPanel/HighScoreGratz

@onready var retry_button = $GameOverPanel/RetryButton
@onready var game_over_quit_button = $GameOverPanel/QuitButton

@onready var ready_screen = $ReadyScreen

signal game_start
signal toggle_pause

var stop_clock = false
static var time_elapsed : float = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	time_elapsed = 0
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !stop_clock:
		time_elapsed += delta
		
		var mins_n_secs = {"mins":str(time_elapsed / 60).pad_decimals(0).pad_zeros(2), "secs":str(fmod(time_elapsed, 60)).pad_decimals(2).pad_zeros(2)}
		time_label.text = "{mins}:{secs}".format(mins_n_secs)

func show_game_over(new_high : bool = false):
	
	game_over_panel.show()
	
	set_game_over_score_text(str(GameManager.score), new_high)
	
	game_over_gratz.visible = new_high

func set_game_over_score_text(text : String, new_high : bool = false):
	
	if new_high:
		game_over_score.text = "[center][wave amp=50.0 freq=5.0 connected=1][rainbow freq=1.0 sat=0.8 val=0.8]{text}[/rainbow][/wave][/center]".format({"text":text})
	else:
		game_over_score.text = "[center]{text}[/center]".format({"text":text})

func on_toggle_pause():
	toggle_pause.emit()
	pause_panel.visible = get_tree().paused
	
func _on_pause_button_pressed() -> void:
	pause_button.focus_mode = false
	on_toggle_pause()
		
func _on_ready_button_button_down() -> void:
	game_start.emit()
	ready_screen.hide()

func _on_unpause_button_pressed() -> void:
	on_toggle_pause()
	
func _on_retry_button_pressed() -> void:
	get_tree().reload_current_scene() # Replace with function body.

func _on_restartbutton_pressed() -> void:
	get_tree().reload_current_scene() # Replace with function body.

func _on_quit_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(main_menu)
