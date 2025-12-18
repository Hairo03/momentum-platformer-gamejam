class_name Player
extends CharacterBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var fairy: Sprite2D = $Fairy
@onready var cooldown_timer: Timer = $CooldownTimer
@onready var power_timer: Timer = $PowerTimer
@onready var coyote_timer: Timer = $CoyoteTimer
@onready var wall_coyote_timer: Timer = $WallCoyoteTimer

# Movement Constants
const MOVE_SPEED: int = 120
const JUMP_FORCE: int = -330
const WALL_JUMP_PUSHBACK: int = 200

# Friction Constants
const GROUND_FRICTION: float = 0.10
const ICE_FRICTION: float = 0.0075
const MOMENTUM_FRICTION: float = 0.05
const AIR_ACCELERATION: float = 0.05
const AIR_DECELERATION: float = 0.005
const AIR_TURN_SPEED: float = 0.015
const AIR_BRAKE_SPEED: float = 0.1

# Ability Constants
const ABILITY_DRAG: float = 0.08
const MAX_ABILITY_POWER: float = 450.0
const MIN_ABILITY_POWER: float = 100.0
const POWER_CHARGE_RATE: float = 8.0

# Fairy Constants
const FAIRY_REST_POSITION: Vector2 = Vector2(10, -4)
const FAIRY_TWEEN_DURATION: float = 0.2

var _trajectory_end_point: Vector2 = Vector2.ZERO

# Ability state - consolidated
var _is_charging_ability: bool = false
var _ability_available: bool = true
var _current_ability_power: float = MIN_ABILITY_POWER

# Movement state
var current_friction: float = GROUND_FRICTION
var is_dead: bool = false
var on_ice: bool = false
var _input_direction: float = 0.0

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var wall_gravity: float = gravity / 10
var current_gravity: float = gravity

var _fairy_tween: Tween

func _process(delta: float) -> void:
	if is_dead:
		return
	
	_fairy_tween = get_tree().create_tween()
	if _is_charging_ability:
		_fairy_tween.tween_property(fairy, "position", _trajectory_end_point, 0.2)
	else:
		_fairy_tween.tween_property(fairy, "position", FAIRY_REST_POSITION, 0.1)
		if _ability_available:
			_fairy_tween.tween_property(fairy, "modulate", Color(1, 1, 1, 1), 0.1)
		else:
			_fairy_tween.tween_property(fairy, "modulate", Color(0, 0, 0, 0), 0.1)

func _physics_process(delta: float) -> void:
	if is_dead:
		return

	print_debug("on_ice: ", on_ice)

	current_gravity = get_current_gravity()
	_input_direction = Input.get_axis("left", "right")

	handle_movement(delta)
	var was_on_floor := is_on_floor()
	var was_on_wall := is_on_wall_only()
	handle_animation()
	handle_friction()
	handle_ability()
	handle_jump()
	handle_death()
	move_and_slide()
	
	if was_on_floor and not is_on_floor():
		coyote_timer.start()
	elif was_on_wall and not is_on_wall_only():
		wall_coyote_timer.start()

	queue_redraw()

func handle_ability() -> void:
	if not cooldown_timer.is_stopped():
		return
	if not _can_use_ability():
		return
	
	if Input.is_action_pressed("left_mouse"):
		_charge_ability()
	
	if Input.is_action_just_released("left_mouse"):
		_release_ability()

func _charge_ability() -> void:
	_is_charging_ability = true
	_current_ability_power = minf(_current_ability_power + POWER_CHARGE_RATE, MAX_ABILITY_POWER)

func _release_ability() -> void:
	var direction := (get_global_mouse_position() - global_position).normalized()
	var power := clampf(_current_ability_power, MIN_ABILITY_POWER, MAX_ABILITY_POWER)
	
	velocity = direction * power
	
	_current_ability_power = MIN_ABILITY_POWER
	_ability_available = false
	_is_charging_ability = false
	cooldown_timer.start()

func _can_use_ability() -> bool:
	if is_on_floor() and not on_ice:
		_ability_available = true
	
	return _ability_available

func handle_movement(delta: float) -> void:
	_apply_gravity(delta)
	_apply_horizontal_movement(_input_direction)
	_update_sprite_direction()

func _apply_gravity(delta: float) -> void:
	if is_on_floor():
		return
	
	if _is_charging_ability:
		velocity = velocity.lerp(Vector2.ZERO, ABILITY_DRAG)
	else:
		velocity.y += current_gravity * delta

func _apply_horizontal_movement(input_dir: float) -> void:
	if _is_charging_ability:
		if is_on_floor():
			velocity.x = lerpf(velocity.x, 0.0, current_friction)
		return
	
	if is_on_floor():
		_apply_ground_movement(input_dir)
	else:
		_apply_air_movement(input_dir)

func _apply_ground_movement(input_dir: float) -> void:
	current_gravity = gravity
	
	var is_going_fast := absf(velocity.x) > MOVE_SPEED
	var is_turning := input_dir != 0 and signf(input_dir) != signf(velocity.x)
	
	if is_going_fast:
		var friction := minf(MOMENTUM_FRICTION, current_friction)
		velocity.x = lerpf(velocity.x, 0.0, friction)
		
		if is_turning:
			velocity.x = lerpf(velocity.x, 0.0, AIR_BRAKE_SPEED)
	elif input_dir:
		velocity.x = lerpf(velocity.x, input_dir * MOVE_SPEED, current_friction * 0.5)
	else:
		velocity.x = lerpf(velocity.x, 0.0, current_friction * 0.75)

func _apply_air_movement(input_dir: float) -> void:
	if not input_dir:
		velocity.x = lerpf(velocity.x, 0.0, AIR_DECELERATION)
		return
	
	var is_going_fast := absf(velocity.x) > MOVE_SPEED
	var same_direction := signf(velocity.x) == input_dir
	
	if is_going_fast:
		var speed := AIR_DECELERATION if same_direction else AIR_TURN_SPEED
		velocity.x = lerpf(velocity.x, 0.0 if same_direction else input_dir * MOVE_SPEED, speed)
	else:
		velocity.x = lerpf(velocity.x, input_dir * MOVE_SPEED, AIR_ACCELERATION)

func _update_sprite_direction() -> void:
	if velocity.x > 0:
		animated_sprite_2d.flip_h = false
		fairy.flip_h = false
	elif velocity.x < 0:
		animated_sprite_2d.flip_h = true
		fairy.flip_h = true

func handle_death() -> void:
	for i in get_slide_collision_count():
		var collision := get_slide_collision(i)
		var collider := collision.get_collider()
		
		if collider is TileMapLayer:
			var hit_pos := collision.get_position() - collision.get_normal()
			var local_pos = collider.to_local(hit_pos)
			var cell = collider.local_to_map(local_pos)
			
			var data = collider.get_cell_tile_data(cell)
			if data:
				var is_hazard: bool = data.get_custom_data("isHazard")
				if is_hazard:
					die()

func handle_jump() -> void:
	if Input.is_action_just_pressed("jump"):
		if is_on_floor() or not coyote_timer.is_stopped():
			if on_ice:
				print_debug("On ice")
				velocity.x *= 1.30
			velocity.y = JUMP_FORCE
		elif is_on_wall_only() or not wall_coyote_timer.is_stopped():
			var jump_dir := get_wall_normal()
			velocity.x = jump_dir.x * WALL_JUMP_PUSHBACK
			velocity.y = JUMP_FORCE
	
	if Input.is_action_just_released("jump"):
		velocity.y *= 0.5

func get_current_gravity() -> float:
	if is_on_wall_only() and velocity.y > 0:
		return wall_gravity
	else:
		return gravity

func handle_animation() -> void:
	if _input_direction != 0:
		animated_sprite_2d.play("run")
	else:
		animated_sprite_2d.play("idle")

func handle_friction() -> void:
	if not is_on_floor():
		return
	
	var found_ice := false
	var found_ground := false
	
	for i in get_slide_collision_count():
		var collision := get_slide_collision(i)
		var collider := collision.get_collider()
		
		if collider is TileMapLayer:
			var hit_pos := collision.get_position() - collision.get_normal()
			var local_pos = collider.to_local(hit_pos)
			var cell = collider.local_to_map(local_pos)
			
			var data = collider.get_cell_tile_data(cell)
			if data:
				var is_ice: bool = data.get_custom_data("isIce")
				if is_ice:
					found_ice = true
				else:
					found_ground = true
	
	if found_ice:
		on_ice = true
		current_friction = ICE_FRICTION
	elif found_ground:
		on_ice = false
		current_friction = GROUND_FRICTION

func reset() -> void:
	velocity = Vector2.ZERO
	is_dead = false

func die() -> void:
	print_debug("Player died.")
	is_dead = true
	await get_tree().create_timer(0.5).timeout
	GameManager.respawn_player()

func _draw() -> void:
	if _is_charging_ability:
		var start_pos := Vector2.ZERO
		var direction := get_local_mouse_position().normalized()
		var power := clampf(_current_ability_power, MIN_ABILITY_POWER, MAX_ABILITY_POWER)
		var sim_velocity := direction * power

		var dt := 0.02
		var max_time := 0.2
		_trajectory_end_point = start_pos
		
		for i in range(int(max_time / dt)):
			var next_point := _trajectory_end_point + sim_velocity * dt
			sim_velocity.y += dt * gravity

			draw_line(_trajectory_end_point, next_point, Color(1, 1, 1, 0.25), 2.0)
			_trajectory_end_point = next_point
