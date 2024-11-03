extends CanvasLayer

var main_menu = "res://Scenes/Menu/MainMenu.tscn"

@onready var score_label = $ScorePanel/ScoreVal
@onready var high_label = $ScorePanel/HighVal
@onready var count_label = $ScorePanel/CountVal
@onready var level_val = $ScorePanel/LevelVal
@onready var time_label = $ScorePanel/TimeVal

@onready var next_preview = [$ScorePanel/LittleGuy, $ScorePanel/LittleGuy2, $ScorePanel/LittleGuy3, $ScorePanel/LittleGuy4, $ScorePanel/LittleGuy5, $ScorePanel/LittleGuy6, $ScorePanel/LittleGuy7, $ScorePanel/LittleGuy8, $ScorePanel/LittleGuy9, $ScorePanel/LittleGuy10]
@onready var next_highlight = [$ScorePanel/NextHighlight, $ScorePanel/NextHighlight2, $ScorePanel/NextHighlight3, $ScorePanel/NextHighlight4, $ScorePanel/NextHighlight5, $ScorePanel/NextHighlight6, $ScorePanel/NextHighlight7, $ScorePanel/NextHighlight8, $ScorePanel/NextHighlight9, $ScorePanel/NextHighlight10]
@onready var spawn_timer_bar = $ScorePanel/TimeProg
@onready var spawn_timer_label = $ScorePanel/TimeProg/Label

@onready var pause_panel = $PausePanel
@onready var pause_button = $PauseButton

@onready var restart_button = $PausePanel/Restartbutton
@onready var unpause_button = $PausePanel/LevelButton
@onready var quit_button = $PausePanel/QuitButton

@onready var game_over_panel = $GameOverPanel
@onready var game_over_score = $GameOverPanel/RichTextLabel
@onready var game_over_gratz = $GameOverPanel/HighScoreGratz

@onready var retry_button = $GameOverPanel/RetryButton
@onready var game_over_quit_button = $GameOverPanel/QuitButton

@onready var ready_screen = $ReadyScreen

@onready var unseen_guys_label = $ScorePanel/UnseenGuys

var current_preview_guys_shown : int = 3

signal game_start
signal toggle_pause

var stop_clock = false
static var time_elapsed : float = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_theme_based_on_options()
	time_elapsed = 0
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !stop_clock:
		time_elapsed += delta
		
		var mins_n_secs = {"mins":str(time_elapsed / 60).pad_decimals(0).pad_zeros(2), "secs":str(fmod(time_elapsed, 60)).pad_decimals(2).pad_zeros(2)}
		time_label.text = "{mins}:{secs}".format(mins_n_secs)

func set_theme_based_on_options():
	for thing in get_children():
		thing.theme = Options.theme_presets[Options.current_theme_index]

func show_game_over(new_high : bool = false):
	
	game_over_panel.show()
	
	set_game_over_score_text(str(GameManager.score), new_high)
	
	game_over_gratz.visible = new_high

func set_game_over_score_text(text : String, new_high : bool = false):
	
	if new_high:
		game_over_score.text = "[center][wave amp=50.0 freq=5.0 connected=1][rainbow freq=1.0 sat=0.8 val=0.8]{text}[/rainbow][/wave][/center]".format({"text":text})
	else:
		game_over_score.text = "[center]{text}[/center]".format({"text":text})

func set_number_of_next_preview_shown(value: int):
	
	#For i in the length of next preview...
	for i in len(next_preview):
		
		#Get the current preview Little Guy instance.
		var current_preview_guy = next_preview[i]
		
		#Check if the current index + 1 is less than or equal to the value. If it is, then it should be shown.
		if i+1 <= value and i+1:
			current_preview_guy.show()
		else:
			current_preview_guy.hide()
			
	#Set this variable. It will be useful later.
	current_preview_guys_shown = value

#Same code as above, but we're iterating through the next_highlight array instead.			
func set_number_of_next_highlight_shown(value: int):
	
	#Unseen Guys Counter starts at 0.
	var unshown_preview_guy_highlights = 0
	
	#For each guy preview highlighter...
	for i in len(next_highlight):
		var current_preview_highlight = next_highlight[i]
		
		#If the index of this counter +1 is less than or equal to the amount we need to show...
		if i+1 <= value:
			
			#If the index of this counter is lesster than or equal to the number of guys actually shown, show the guy. We have something to highlight
			if i <= current_preview_guys_shown:
				current_preview_highlight.show()
				
				#This is for modes where you spawn guys that you can't see. You see this unseen guy label's text notation instead.
				if i == current_preview_guys_shown:
					unseen_guys_label.show()
					unshown_preview_guy_highlights += 1
					unseen_guys_label.set_position(current_preview_highlight.position)
			
			#What's that? You need to highlight some guys you cannot see? We'll add it to the unseen counter instead.
			else:
				unshown_preview_guy_highlights += 1
		else:
			#Hide the highlighter if you aren't supposed to see it.
			current_preview_highlight.hide()
		
		#Finally, update the unseen guy label.
		unseen_guys_label.text = "+{count}".format({"count":unshown_preview_guy_highlights})

func on_toggle_pause():
	toggle_pause.emit()
	
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
	
func _on_level_button_pressed() -> void:
	get_tree().paused = false
	Options.instant_level_select = true
	
	get_tree().change_scene_to_file(main_menu)
	
	
