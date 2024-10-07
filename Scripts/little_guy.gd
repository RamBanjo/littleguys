extends RigidBody2D

class_name LittleGuy

enum BodyParts{
	BODY=0, EYES=1, MOUTH=2
}

enum LittleGuyBody {
	CIRCLE=0, SQUARE=1, TRIANGLE=2, HEXAGON=3
}

enum LittleGuyEyes{
	ROUND=0, GLASSES=1, HEART=2, CYCLOPS=3
}

enum LittleGuyMouth{
	W=0, LIP=1, MOUSTACHE=2, TEETH=3
}

static var sprites_dict = {
	BodyParts.BODY: {
		LittleGuyBody.CIRCLE: load("res://Sprites/CreatureBody/circle_body.png"),
		LittleGuyBody.SQUARE: load("res://Sprites/CreatureBody/red_square.png"),
		LittleGuyBody.TRIANGLE: load("res://Sprites/CreatureBody/triangle_body.png"),
		LittleGuyBody.HEXAGON: load("res://Sprites/CreatureBody/hexagon_body.png"),
	},
		BodyParts.EYES: {
		LittleGuyEyes.ROUND: load("res://Sprites/CreatureEyes/round_eyes.png"),
		LittleGuyEyes.GLASSES: load("res://Sprites/CreatureEyes/glasses_eyes.png"),
		LittleGuyEyes.HEART: load("res://Sprites/CreatureEyes/heart_eyes.png"),
		LittleGuyEyes.CYCLOPS: load("res://Sprites/CreatureEyes/cyclops_eye.png"),
	},
		BodyParts.MOUTH: {
		LittleGuyMouth.W: load("res://Sprites/CreatureMouth/w_mouth.png"),
		LittleGuyMouth.LIP: load("res://Sprites/CreatureMouth/lips_mouth.png"),
		LittleGuyMouth.MOUSTACHE: load("res://Sprites/CreatureMouth/stache_mouth.png"),
		LittleGuyMouth.TEETH: load("res://Sprites/CreatureMouth/grin_mouth.png"),
	}
}

@onready var collision_by_body_type = {
	LittleGuyBody.CIRCLE: $CircleCollision,
	LittleGuyBody.TRIANGLE: $TriangleCollision,
	LittleGuyBody.SQUARE: $SquareCollision,
	LittleGuyBody.HEXAGON: $HexagonCollision
}

@onready var part_sprites = {
	BodyParts.BODY : $LittleGuyBody,
	BodyParts.EYES : $LittleGuyEyes,
	BodyParts.MOUTH : $LittleGuyMouth
}

@onready var visibility_notif = $VisibleOnScreenNotifier2D

var my_collision

#@export var my_body : LittleGuyBody
#@export var my_eyes : LittleGuyEyes
#@export var my_mouth : LittleGuyMouth

var my_parts = {
			BodyParts.BODY: LittleGuyBody.CIRCLE,
			BodyParts.EYES: LittleGuyEyes.ROUND,
			BodyParts.MOUTH: LittleGuyMouth.W
	}

const HOVERING_DICT_DEFAULT = {"little_guys":[], "part":null}
static var hovering_group = HOVERING_DICT_DEFAULT
static var current_hovered_guy : LittleGuy = null

signal guy_fell_off
signal guy_clicked

# When spawned, choose a random type of body part for each enum here, then draw them on the Little Guy.

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	setup_collider()
	#
	##For each body part, we will assign the sprite with the appropriate part to it.
	update_part_graphics()

func clone_guy_data(guy_data):
	for part in LittleGuy.BodyParts.values():
		self.my_parts[part] = guy_data[part]	

func setup_collider():
	for my_collider in collision_by_body_type.values():
		my_collider.set_deferred("disabled", true)

	my_collision = collision_by_body_type[my_parts[BodyParts.BODY]]
	my_collision.set_deferred("disabled", false)

func update_part_graphics():
	for part in BodyParts.values():
		var current_parts_type = my_parts[part]
		part_sprites[part].texture = sprites_dict[part][current_parts_type]	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func set_alpha_on_sprites(alpha: float):
	
	#For each body part sprite...
	for part in BodyParts.values():
		var current_sprite = part_sprites[part] as Sprite2D
		
		#Set the alpha of that sprite to the appropriate value.
		current_sprite.modulate.a = alpha


func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	
	#When we left click the little guy...
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed == true:
			
			#...we'll send the signal to the GameManager with the value of the number of guys that will clear...
			var clear_group = get_highest_count_group_with_adjacent_trait()
			guy_clicked.emit(len(clear_group["little_guys"]))
			
			
			#...then it will clear.
			for little_guy in clear_group["little_guys"]:
				#We also wake up anyone adjacent to someone who just got cleared.
				for adjacent_guy in little_guy.get_colliding_bodies():
					if adjacent_guy is LittleGuy:
						adjacent_guy.sleeping = false
						
				little_guy.queue_free()
				
			
				
			#We will get score according to the amount cleared. Send this to the GameManager.
			



#Must force Exited to process BEFORE Entered
func _on_mouse_exited() -> void:
	clear_current_hovered_guys()
	#print("Exited: {me}".format({"me": self}))

func _on_mouse_entered() -> void:
	
	#To ensure that we always exit before entering, we make it delay a bit.
	await get_tree().create_timer(0.01).timeout
	
	current_hovered_guy = self
	hovering_group = get_highest_count_group_with_adjacent_trait()
	for little_guy in hovering_group["little_guys"]:
		little_guy.set_alpha_on_sprites(0.5)
		
		
static func clear_current_hovered_guys():
	current_hovered_guy = null
	for little_guy in hovering_group["little_guys"]:
		if little_guy != null:
			little_guy.set_alpha_on_sprites(1)
	
	hovering_group = HOVERING_DICT_DEFAULT.duplicate()			
		
func get_highest_count_group_with_adjacent_trait():
	
	var adjacency_check_results = Dictionary()
	var max_list = [self]
	var max_adjacencies = -999
	var max_part = null
	
	#We will check for adjacencies for all the traits.
	for part in BodyParts.values():
		adjacency_check_results[part] = get_adjacent_guy_with_same_trait(part)
		
		#If the list's count is higher than the current count, then we'll replace the MAXes with the new find.
		#Since BodyParts.values() is ordered by BODY -> EYES -> MOUTH already, it will always use that as a priority when more than one trait is equal.
		if len(adjacency_check_results[part]) > max_adjacencies:
			max_list = adjacency_check_results[part]
			max_adjacencies = len(max_list)
			max_part = part
			
	return {"little_guys": max_list, "part": max_part}

func get_adjacent_guy_with_same_trait(check_part : BodyParts, checked_guys_list = [self], same_trait_guys_list = [self]):
	
	if check_part == null:
		return [self]
	
	#Get a list of all the things colliding with this rigidbody
	var colliding_things = get_colliding_bodies()
	
	var new_same_trait_guys_list = []
	
	#For each thing in the list of colliding things...
	for thing in colliding_things:
		
		#If it's a LittleGuy and we haven't seen it yet...
		if thing is LittleGuy and thing not in checked_guys_list:
			var adjacent_guy = thing as LittleGuy
			
			#Mark the thing as seen
			checked_guys_list.append(adjacent_guy)
			
			#Additionally, if the part of the thing we're checking is the same as the part on this LittleGuy that we want to check, then add it to the list of guys with maching trait.
			if adjacent_guy.my_parts[check_part] == my_parts[check_part]:
				new_same_trait_guys_list.append(adjacent_guy)
				
	#If we don't see anything new, this function is complete and we can return the list of guys with the same trait that are touching.
	if len(new_same_trait_guys_list) == 0:
		return same_trait_guys_list
		
	#If not...
	else:
		
		#We add the new guys we have seen to the list of the guys that we have already seen
		var full_list = []
		
		for new_guy in new_same_trait_guys_list:
			var new_guy_casted = new_guy as LittleGuy
			same_trait_guys_list.append_array(new_same_trait_guys_list)
			
			#Then for each of the guys in this iteration, we call this function for them, with the added knowledge of the guys we have already checked.
			full_list.append_array(new_guy_casted.get_adjacent_guy_with_same_trait(check_part, checked_guys_list, same_trait_guys_list))
		
		#Since we run each function parallel, it's possible to have some duplicates. We'll eliminate duplicates here.
		var unique = []
		for item in full_list:
			if item not in unique:
				unique.append(item)
				
		return unique

#If something else begins touching me...
func _on_body_entered(body: Node) -> void:

	#If I'm in the hovering group, and the other object is a Little Guy...
	
	if self in hovering_group["little_guys"] and body is LittleGuy:
		var other_little_guy = body as LittleGuy

		#If the other guy isn't in the hovering group and the property we're checking for happens to match, it should be in the hovering group. Add it!
		#print(other_little_guy not in hovering_group)
		if other_little_guy not in hovering_group["little_guys"] and self.my_parts[hovering_group["part"]] == other_little_guy.my_parts[hovering_group["part"]]:
			
			#We'll add the other guy to the hovering group! Yay! We also make it translucent
			hovering_group["little_guys"].append(other_little_guy)
			other_little_guy.set_alpha_on_sprites(0.5)


#If something else stops touching me...
func _on_body_exited(body: Node) -> void:
	
	self.sleeping = false
	
	#If the other guy is a LittleGuy that's not currently being hovered AND we are currently hovering something...
	if body is LittleGuy and not hovering_group["little_guys"].is_empty() and body != current_hovered_guy:
		var other_little_guy = body as LittleGuy
		
		#If I'm in the hovering_group or the other guy is also in the hovering_group
		if self in hovering_group["little_guys"] or other_little_guy in hovering_group["little_guys"]:
			
			#We'll see if either of us can find our way back to the current_hovering_guy. Anyone that can't will be removed from the hovering_guys_list.	
			if not self.is_linked_to_current_hovered_guy([self, other_little_guy]):
				hovering_group["little_guys"].erase(self)
				set_alpha_on_sprites(1)
			if not other_little_guy.is_linked_to_current_hovered_guy([self, other_little_guy]):
				hovering_group["little_guys"].erase(other_little_guy)
				other_little_guy.set_alpha_on_sprites(1)

func is_linked_to_current_hovered_guy(exclusions = []):
	
	#If I'm the current_hovered_guy, then I already have a link. Return true.
	if self == current_hovered_guy:
		return true
	
	#Otherwise, get the list of LittleGuys that I'm colliding with
	var list_of_guys = get_adjacent_guy_with_same_trait(hovering_group["part"])
	
	#Make sure to not check for things we specifically ask the function not to
	for excluded_guy in exclusions:
		list_of_guys.erase(excluded_guy)
	
	#If we can't find the current hovered guy from here, then it is false. Likewise if we can, it's true.
	return current_hovered_guy in list_of_guys
		#return false
	#return true


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
	guy_fell_off.emit()
