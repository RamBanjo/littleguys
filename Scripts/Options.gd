extends Node

class_name Options

static var max_bgm_volume : float = 1
static var max_sfx_volume : float = 1
static var resolution : Vector2 = Vector2(1600, 900)
static var fullscreen : bool = false
static var instant_level_select : bool = false
static var current_theme_index = 0

static var theme_presets = {
	0: load("res://Themes/little_guy_theme.tres"),
	1: load("res://Themes/little_guy_theme_pixelfont.tres")
}


enum BackgroundOption{
	SCROLLING=0, STATIC=1, EMPTY=2
}

static var background_scroll : BackgroundOption = BackgroundOption.SCROLLING
	
