extends Node2D

##For when you want to export to the web. I'm thinking Web Export might break if I change resolution.
@export var skip_screen_options : bool = false

@onready var guy_spawner : GuySpawner = $GuySpawner
@onready var guy_timer : Timer = $AutoSpawnTimer

@onready var main_menu_canvas = $MainMenuCanvas
@onready var current_canvas = main_menu_canvas

@onready var tutorial_canvas = $TutorialCanvas
@onready var tutorial_canvas_2 = $TutorialCanvas2
@onready var tutorial_canvas_3 = $TutorialCanvas3
@onready var level_picker_canvas = $LevelPickerCanvas
@onready var options_canvas = $OptionsCanvas
@onready var credits_canvas = $CreditsCanvas

@onready var bgm_slider = $OptionsCanvas/BGMSlider
@onready var sfx_slider = $OptionsCanvas/SFXSlider
@onready var resolution_list = $OptionsCanvas/ResList
@onready var resolution_button = $OptionsCanvas/ConfirmResolutionButton
@onready var full_screen_button = $OptionsCanvas/FullScreenToggleButton
@onready var game_bg_picker = $OptionsCanvas/GameBackgroundPicker
@onready var theme_picker = $OptionsCanvas/FontPicker

@onready var bgm_object = $AudioStreamPlayer
@onready var sfx_player = $SFXPlayer

@onready var level_picker_list = [$LevelPickerCanvas/BasicBlockPicker, $LevelPickerCanvas/HourglassPicker, $LevelPickerCanvas/PachinkoPicker, $LevelPickerCanvas/SpinnerPicker, $LevelPickerCanvas/BlenderPicker, $LevelPickerCanvas/PolyrhythmPicker, $LevelPickerCanvas/NoOSHAPicker, $LevelPickerCanvas/ShakePicker, $LevelPickerCanvas/FootballPicker, $LevelPickerCanvas/BottomlessPicker]

@onready var game_mode_sfx = {
	GameManager.GameMode.TIME_ATTACK: $LevelPickerCanvas/OptionButton/GameModeChooserSFX/TimeAttack,
	GameManager.GameMode.STRATEGIC: $LevelPickerCanvas/OptionButton/GameModeChooserSFX/Strategic,
	GameManager.GameMode.CHILL: $LevelPickerCanvas/OptionButton/GameModeChooserSFX/Chill,
	GameManager.GameMode.CRUEL: $LevelPickerCanvas/OptionButton/GameModeChooserSFX/AreYouSure
}
@onready var game_mode_selector = $LevelPickerCanvas/OptionButton

@onready var parallax_bg = $ParallaxBackground

var theme_object = "res://Themes/little_guy_theme.tres"

static var preset_res = {
	0: Vector2(800, 450),
	1: Vector2(1280, 720),
	2: Vector2(1600, 900),
	3: Vector2(1920, 1080)
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	initialize_settings()
	bgm_object.play()
	
	if Options.instant_level_select:
		Options.instant_level_select = false
		open_level_select_menu()
	#bgm_object.autoplay = true
	
	#pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func initialize_settings():
	var config = ConfigFile.new()
	var err = config.load("user://options.cfg")
	
	if err != OK:
		
		config.set_value("option", "bgm", 1)
		config.set_value("option", "sfx", 1)
		config.set_value("option", "parallax", Options.BackgroundOption.SCROLLING)
		config.set_value("option", "theme_idx", 0)
		
		if not skip_screen_options:
			config.set_value("option", "res", Vector2(1600, 900))
			config.set_value("option", "fullscreen", false)
		
		config.save("user://options.cfg")
		#Default Settings
	
	Options.max_bgm_volume = config.get_value("option", "bgm", 1)
	Options.max_sfx_volume = config.get_value("option", "sfx", 1)
	Options.background_scroll = config.get_value("option", "parallax", Options.BackgroundOption.SCROLLING)
	Options.current_theme_index = config.get_value("option", "theme_idx", 0)
	
	if not skip_screen_options:
		Options.resolution = config.get_value("option", "res", Vector2(1600, 900))
		Options.fullscreen = config.get_value("option", "fullscreen", false)
	
	bgm_object.volume_db = linear_to_db(Options.max_bgm_volume)
	sfx_player.set_max_volume(Options.max_sfx_volume)
	
	bgm_slider.value = Options.max_bgm_volume * bgm_slider.max_value
	sfx_slider.value = Options.max_sfx_volume * sfx_slider.max_value
	
	game_bg_picker.selected = Options.background_scroll
	theme_picker.selected = Options.current_theme_index
	
	parallax_bg.update_background_settings()
	set_theme(Options.current_theme_index)
	
	if not skip_screen_options:
		set_resolution(Options.resolution)
		
		if Options.fullscreen:
			get_tree().root.mode = Window.MODE_FULLSCREEN
		
		resolution_button.disabled = Options.fullscreen
		
	game_mode_selector.selected = GameManager.current_game_mode
	
func _on_play_button_pressed() -> void:
	open_level_select_menu()

func open_level_select_menu():
	main_menu_canvas.hide()
	level_picker_canvas.show()
	current_canvas = level_picker_canvas
	toggle_background_guy_fountain(false)	

func _on_tutorial_button_pressed() -> void:
	main_menu_canvas.hide()
	tutorial_canvas.show()
	current_canvas = tutorial_canvas
	toggle_background_guy_fountain(false)

func _on_options_button_pressed() -> void:
	main_menu_canvas.hide()
	options_canvas.show()
	current_canvas = options_canvas
	toggle_background_guy_fountain(false)

func _on_credits_button_pressed() -> void:
	main_menu_canvas.hide()
	credits_canvas.show()
	current_canvas = credits_canvas
	toggle_background_guy_fountain(false)

func _on_close_button_pressed() -> void:
	current_canvas.hide()
	main_menu_canvas.show()
	current_canvas = main_menu_canvas
	toggle_background_guy_fountain(true)

func _on_quit_button_pressed() -> void:
	get_tree().quit()

func _on_tutorial_back_button_pressed() -> void:
	tutorial_canvas_2.hide()
	tutorial_canvas.show()

	current_canvas = tutorial_canvas
	
func _on_tutorial_next_button_pressed() -> void:
	tutorial_canvas.hide()
	tutorial_canvas_2.show()
	
	current_canvas = tutorial_canvas_2


func _on_tutorial_back_2_button_pressed() -> void:
	tutorial_canvas_3.hide()
	tutorial_canvas_2.show()
	
	current_canvas = tutorial_canvas_2


func _on_tutorial_next_2_button_pressed() -> void:
	tutorial_canvas_2.hide()
	tutorial_canvas_3.show()

	current_canvas = tutorial_canvas_3
#func make_guy_from_game_manager():
	#var guy_data = Dictionary()
	#for part in LittleGuy.BodyParts.values():
		#guy_data[part] = GameManager.grab_part_from_bag(part)			
		#
	#return guy_data

func toggle_background_guy_fountain(enable: bool):
	
	if enable:
		
		for stage_object in get_tree().get_nodes_in_group("stage_object"):
			stage_object.show()
		
		guy_timer.start()
		
	else:

		for stage_object in get_tree().get_nodes_in_group("stage_object"):
			stage_object.hide()

		for little_guy in get_tree().get_nodes_in_group("little_guy"):
			little_guy.queue_free()
			
		guy_timer.stop()
		
			
		pass

func _on_auto_spawn_timer_timeout() -> void:
	var guy_spawned = guy_spawner.spawn_specific_guy(GameManager.make_random_guy_from_bag())
	guy_spawned.input_pickable = false

func _on_confirm_resolution_button_pressed() -> void:
	var new_res = preset_res[resolution_list.get_selected_items()[0]]
	set_resolution(new_res)
	save_current_settings()

func set_resolution(new_res: Vector2):
	Options.resolution = new_res
	get_tree().root.size = new_res

func _on_full_screen_toggle_button_pressed() -> void:
	
	if Options.fullscreen:
		get_tree().root.mode = Window.MODE_WINDOWED
		Options.fullscreen = false
	else:
		get_tree().root.mode = Window.MODE_FULLSCREEN
		Options.fullscreen = true
		
	resolution_button.disabled = Options.fullscreen
	
	save_current_settings()

func _on_bgm_slider_drag_ended(value_changed: bool) -> void:
	bgm_slider.set_focus_mode(Control.FOCUS_NONE)
	
	Options.max_bgm_volume = bgm_slider.value / bgm_slider.max_value
	
	bgm_object.volume_db = linear_to_db(Options.max_bgm_volume)
	
	save_current_settings()
	
func _on_sfx_slider_drag_ended(value_changed: bool) -> void:
	sfx_slider.set_focus_mode(Control.FOCUS_NONE)

	Options.max_sfx_volume = sfx_slider.value / sfx_slider.max_value
	
	sfx_player.set_max_volume(Options.max_sfx_volume)
	sfx_player.play_sfx(SFXPlayer.SFXType.GREAT_CLEAR)
	for game_mode_sfx_obj in game_mode_sfx.values():
		game_mode_sfx_obj.volume_db = linear_to_db(Options.max_sfx_volume)
	save_current_settings()

func _on_game_background_picker_item_selected(index: int) -> void:
	game_bg_picker.set_focus_mode(Control.FOCUS_NONE)
	
	Options.background_scroll = game_bg_picker.get_selected_id()
	
	parallax_bg.update_background_settings()
	
	save_current_settings()

func save_current_settings():
	var config = ConfigFile.new()
	
	config.set_value("option", "bgm", Options.max_bgm_volume)
	config.set_value("option", "sfx", Options.max_sfx_volume)
	config.set_value("option", "res", Options.resolution)
	config.set_value("option", "fullscreen", Options.fullscreen)
	config.set_value("option", "parallax", Options.background_scroll)
	config.set_value("option", "theme_idx", Options.current_theme_index)
	
	config.save("user://options.cfg")


func _on_option_button_item_selected(index: int) -> void:
	game_mode_selector.set_focus_mode(Control.FOCUS_NONE)
	
	GameManager.current_game_mode = index
	
	for level_picker in level_picker_list:
		level_picker.update_highscore_label()
	
	game_mode_sfx[GameManager.current_game_mode].play()

func set_theme(theme_index : int):
	for thing in get_children(true):
		if thing is CanvasLayer:
			for subthing in thing.get_children():
				if subthing is Control and not subthing.is_in_group("theme_change_ignore"):
					subthing.theme = Options.theme_presets[theme_index]

func _on_font_picker_item_selected(index: int) -> void:
	set_theme(index)
	Options.current_theme_index = index
	
	save_current_settings()
	#print(Options.theme_presets[index])
	#pass # Replace with function body.
