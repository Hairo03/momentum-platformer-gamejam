extends CharacterBody2D

@export_category("Movement Params")
@export var speed = 200.0
@export var decel_speed = 12.5
@export var accel_speed = 15.0
@export var air_decel = 6.5
@export var air_accel = 9.0
@export var wall_friction = 100.0
@export var slam_speed = 300

@export_category("Jump and Walljump Param")
@export var jump_velocity = -400.0
@export var jump_count : int = 1
@export var walljump_count : int = 2
@export var walljump_pushback = 400


var current_accel
var current_decel
var current_state
var current_jump_count
var current_walljump_count
var is_wall_sliding:bool
var jump_buffer:bool = false

enum  State {Idle, Run, Jump}

@onready var character_body_2d = $"."
@onready var coyote_timer = $CoyoteTimer
@onready var jump_buffer_timer = $JumpBufferTimer
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func player_jump(delta):
	var jump_input : bool = Input.is_action_just_pressed("jump")
	
	if not is_on_floor():
		velocity.y += gravity * delta
		#if velocity.y < 0:
			##sprite_2d.animation = "jumping"
		#else:
			##sprite_2d.animation = "falling"
		current_accel = air_accel
		current_decel = air_decel
		current_state = State.Jump
	else:
		current_accel = accel_speed
		current_decel = decel_speed
		if jump_buffer:
			current_jump_count = 0
			current_walljump_count = 0
			velocity.y = jump_velocity
			current_jump_count += 1
			current_state = State.Jump
	
	# Handle jump.
	if jump_input:
		
		# Handle Jump from Ground
		if is_on_floor() || !coyote_timer.is_stopped():
			current_jump_count = 0
			current_walljump_count = 0
			velocity.y = jump_velocity
			current_jump_count += 1
			current_state = State.Jump
		else:
			jump_buffer = true
			jump_buffer_timer.start()
			if !jump_buffer_timer.is_connected("timeout", on_jump_buffer_timeout):
				jump_buffer_timer.timeout.connect(on_jump_buffer_timeout)
			
		# Handle Wall jump
		if is_on_wall_only() and Input.is_action_pressed("right") and current_walljump_count < walljump_count:
			current_jump_count = 0
			velocity.y = jump_velocity
			velocity.x = -walljump_pushback
			current_walljump_count += 1
			
		if is_on_wall_only() and Input.is_action_pressed("left") and current_walljump_count < walljump_count:
			current_jump_count = 0
			velocity.y = jump_velocity
			velocity.x = walljump_pushback
			current_walljump_count += 1
			
	if Input.is_action_just_released("jump") and velocity.y < 0.0 and !is_on_wall():
		velocity.y *= 0.6

func player_move():
	if ((velocity.x > 1 || velocity.x < -1) || not Input.get_axis("left", "right") == 0):
		animated_sprite_2d.play("run")
		current_state = State.Run
	else:
		animated_sprite_2d.play("idle")
		current_state = State.Idle
		
	# Get the input direction and handle the movement/deceleration.
	var direction = Input.get_axis("left", "right")
	if direction:
		velocity.x = move_toward(velocity.x, direction * speed, accel_speed) 
	else:
		velocity.x = move_toward(velocity.x, 0, decel_speed)
	
	if direction > 0:
		animated_sprite_2d.flip_h = false
	if direction < 0:
		animated_sprite_2d.flip_h = true
	
	var rounded_position = (character_body_2d.position).round()
	character_body_2d.position = rounded_position

func on_jump_buffer_timeout():
	jump_buffer = false
	print_debug("timeout")

func wall_slide(delta):
	if is_on_wall_only():
		if Input.is_action_pressed("right") or Input.is_action_pressed("left"):
			is_wall_sliding = true
		else:
			is_wall_sliding = false
	else:
		is_wall_sliding = false
	
	if is_wall_sliding:
		velocity.y += (wall_friction * delta)
		velocity.y = min (velocity.y, wall_friction)
		#sprite_2d.animation = "wallsliding"

func _physics_process(delta):
	player_move()
	
	var was_on_floor = is_on_floor()
	
	move_and_slide()
	
	player_jump(delta)
	wall_slide(delta)
	
	if was_on_floor and not is_on_floor():
		coyote_timer.start()
