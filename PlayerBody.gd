extends Player


var SPEED = 900.0
var INIT_DASH_SPEED = 2000.0
var DASH_SPEED = 2000.0
var JUMP_VELOCITY = -800.0
const WALL_JUMP_VELOCITY = 50000.0
const TRIPLE_JUMP_VELOCITY = -400.0
const DASH_TIME = 0.5
const DASH_STUN = 0.8
const COPY_WAIT = 0.7

const JUMP_BUFFER = 0.2
var jump_buffer = 0.0

const COYOTE_TIME = 0.2
var can_coyote = true
var coyote_time = 0.0

const DASH_BUFFER = 0.2

# Special constants
const PARRY_BUFFER = 0.15
const PARRY_FORCE = 1400.0
const PARRY_COOLDOWN = 1.0

const TIME_STOP_BUFFER = 2.5
const SLOWED_TIME_MULT = 0.25
const TIME_STOP_COOLDOWN = 5.0

const STUN_SHOT_COOLDOWN = 1.0

const SHOVING_BUFFER = 0.25
const SHOVING_COOLDOWN = 2.0

const TELEPORT_COOLDOWN = 5.0

# Special variables
var parry_buffer = 0.0
var parry_cooldown = -1.0

var time_stop_buffer = 0.0
var time_stop_cooldown = -1.0

var stun_shot_cooldown = 0.0
var can_stun_shot = true

var shoving = false
var shoving_buffer = 0.0
var shoving_cooldown = 0.0

var teleport_cooldown = 0.0

var last_dir: Vector2
var direction: Vector2
var time_mult = 1.0

var hit_velocity: Vector2
var hit_reversed = false

@export var stun_shot_parent: HitArea
@onready var radial_shove_area = $RadialShove
@onready var teleport_point = $"../TeleportPoint"
@export var sprite: Sprite2D
@onready var cool_down_text = $CoolDownText
@export var collider: CollisionShape2D
@export var spawn_point: Node2D

const SPRITE_SQUASH = 0.1
var sprite_width: float

@export var copies: Node2D
var copy = 1
var copy_wait = COPY_WAIT

@export var hit_area: HitArea

# Get the gravity from the project settings to be synced with RigidBody nodes.
var GRAVITY = ProjectSettings.get_setting("physics/2d/default_gravity")
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var can_dash = false
var dashing = false
var second_dash = false
var dash_time = DASH_TIME
var dash_stun = 0.0
var dash_dir = Vector2.ZERO
var dash_buffered = false

@export var wall_climb: WallClimb
var climbing_wall = false

@export var camera: Camera2D
@export var other_player: Player

func _enter_tree():
	if special == Special.Random:
		var r = randi_range(0, 11)
		special = r
		print(special)

	if perk == Perk.Random:
		var r = randi_range(0, 8)
		perk = r


func _ready():
	match perk:
		Perk.SizeIncrease:
			sprite.scale *= 1.25
			collider.scale *= 1.25
		Perk.SizeDecrease:
			sprite.scale *= 0.75
			collider.scale *= 0.75
		Perk.SpeedIncrease:
			SPEED += 200.0
			JUMP_VELOCITY -= 200.0
		Perk.DashSpeedIncrease:
			DASH_SPEED += 500.0
		Perk.BiggerHitArea:
			hit_area.scale *= 1.5
		Perk.HarderDash:
			hit_area.FORCE *= 1.5
		Perk.SquareCollider:
			var rect = RectangleShape2D.new()
			rect.extents = Vector2(64, 64)
			collider.shape = rect

	INIT_DASH_SPEED = DASH_SPEED

	sprite_width = sprite.scale.x

	var json_string = "[0, 1, 2, 3, 4, 5]"
	var json = JSON.new()

	# Parse the JSON string
	var result = json.parse(json_string)

	if result == OK:
		# Successfully parsed, access the data
		var data = json.get_data()
	else:
		print("Failed to parse JSON")

func respawn():
	position = spawn_point.position
	dashing = false
	can_dash = false
	dash_stun = 0.0
	dash_buffered = false
	hit_velocity = Vector2.ZERO
	sprite.rotation = 0

func _process(delta):
	# if can_dash:
	# 	sprite.modulate.r = 1.0
	# 	sprite.modulate.g = 0.0
	# 	sprite.modulate.b = 0.0
	# elif second_dash:
	# 	sprite.modulate.r = 0.0
	# 	sprite.modulate.g = 1.0
	# 	sprite.modulate.b = 0.0
	# else:
	# 	sprite.modulate.r = 1.0
	# 	sprite.modulate.g = 1.0
	# 	sprite.modulate.b = 1.0

	# *COOL DOWN TEXT*
	match special:
		Special.Parry:
			cool_down_text.display_cool_down(parry_cooldown)
		Special.TimeSlow:
			cool_down_text.display_cool_down(time_stop_cooldown)
		Special.StunShot:
			cool_down_text.display_cool_down(stun_shot_cooldown)
		Special.RadialShove:
			cool_down_text.display_cool_down(shoving_cooldown)
		Special.Teleport:
			cool_down_text.display_cool_down(teleport_cooldown)

	# *COOL DOWNS AND BUFFERS*
	# PARRY
	if parry_buffer > 0.0:
		sprite.modulate.r = 0.0
		sprite.modulate.g = 0.0
		sprite.modulate.b = 1.0

		gravity = 0.0
		direction = Vector2.ZERO
		dash_stun = 0.0
		parry_cooldown = 0.0

		parry_buffer -= delta * time_mult
	elif parry_cooldown == 0.0:
		parry_cooldown = PARRY_COOLDOWN

	if special == Special.Parry && parry_cooldown > 0.0:
		parry_cooldown -= delta * time_mult

	# TIME STOP
	if time_stop_buffer > 0.0:
		camera.slow_time = true
		time_stop_cooldown = 0.0
		other_player.time_mult = SLOWED_TIME_MULT
		time_stop_buffer -= delta * time_mult

		for child in get_parent().get_parent().get_children():
			if child is StunShotArea:
				child.time_mult = SLOWED_TIME_MULT
	elif time_stop_cooldown == 0.0:
		time_stop_cooldown = TIME_STOP_COOLDOWN
		other_player.time_mult = 1.0

		for child in get_parent().get_parent().get_children():
			if child is StunShotArea:
				child.time_mult = 1.0

	# STUN SHOT
	if stun_shot_cooldown > 0.0:
		stun_shot_cooldown -= delta
	else:
		can_stun_shot = true

	# RADIAL SHOVE
	if shoving_buffer > 0.0:
		shoving_buffer -= delta

	if shoving && shoving_buffer <= 0:
		shoving = false
		shoving_cooldown = SHOVING_COOLDOWN

	if shoving_cooldown > 0.0 && !shoving:
		shoving_cooldown -= delta

	# TELEPORT
	if teleport_cooldown > 0.0:
		teleport_cooldown -= delta

	if special == Special.TimeSlow && time_stop_cooldown > 0.0:
		time_stop_cooldown -= delta * time_mult

		sprite.modulate.r = 0.0
		sprite.modulate.g = 1.0
		sprite.modulate.b = 0.0

	copy_wait -= delta

	for i in range(1, 6):
		copies.get_node(str(i)).modulate.a -= delta

	
	if copy_wait <= 0 and dashing:
		copies.get_node(str(copy)).position = position

		copies.get_node(str(copy)).modulate.a = 1

		copy += 1

		if copy > 5:
			copy = 1

	pass

func jump():
	velocity.y = JUMP_VELOCITY
	coyote_time = 0.0

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor() && !(is_on_ceiling() && hit_velocity.y < 0):
		velocity.y += gravity * delta

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	direction = Input.get_vector("Left" + player_num, "Right" + player_num, "Up" + player_num, "Down" + player_num)

	if dashing && direction == Vector2.ZERO:
		direction = last_dir

	if direction:
		velocity.x = direction.x * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	# Handle jump.
	if Input.is_action_just_pressed("Jump" + player_num) and ((is_on_floor() || climbing_wall) || coyote_time > 0.0):
		jump()
	elif Input.is_action_just_pressed("Jump" + player_num):
		jump_buffer = JUMP_BUFFER

	if jump_buffer > 0.0:
		jump_buffer -= delta

	if is_on_floor() && jump_buffer > 0.0:
		jump()

	if is_on_floor():
		can_coyote = true

	if !is_on_floor() && can_coyote:
		coyote_time = COYOTE_TIME
		can_coyote = false

	if coyote_time > 0.0:
		coyote_time -= delta
		
	if is_on_floor() && !dashing:
		can_dash = true

		match special:
			Special.SecondDash:
				second_dash = true

	if !dashing:
		sprite.scale.x = sprite_width

	if dash_stun >= 0.0:
		can_dash = false
		dash_stun -= delta

		sprite.scale.x = sprite_width - SPRITE_SQUASH
	
	if (Input.is_action_just_pressed("Dash" + player_num) && can_dash && !dashing) || (dash_buffered && !dashing && can_dash):
		can_dash = false
		dashing = true
		dash_dir = direction
		dash_buffered = false
		dash_stun = 0.0
	elif Input.is_action_just_pressed("Dash" + player_num) && (dash_time <= DASH_BUFFER) && dashing && !dash_buffered:
		dash_buffered = true

	# Specials
	if Input.is_action_just_pressed("Special" + player_num):
		match special:
			Special.SecondDash:
				if (second_dash && !dashing) || (dash_buffered && !dashing && second_dash):
					second_dash = false
					dashing = true
					dash_dir = direction
					dash_buffered = false
					DASH_SPEED -= 750
			Special.Parry:
				if parry_buffer <= 0.0 && parry_cooldown <= 0.0:
					parry_buffer = PARRY_BUFFER
			Special.TimeSlow:
				if time_stop_buffer <= 0.0 && time_stop_cooldown <= 0.0:
					time_stop_buffer = TIME_STOP_BUFFER
			Special.StunShot:
				if can_stun_shot:
					var new_shot = stun_shot_parent.duplicate()
					new_shot.visible = true
					new_shot.player = self
					new_shot.position = position + get_parent().position

					if get_distance(self, other_player).x > 0:
						new_shot.direction = Vector2(1, 0)
					else:
						new_shot.direction = Vector2(-1, 0)

					get_parent().get_parent().add_child(new_shot)
					
					stun_shot_cooldown = STUN_SHOT_COOLDOWN
					can_stun_shot = false
			Special.RadialShove:
				if shoving_cooldown <= 0.0:
					shoving = true
					shoving_buffer = SHOVING_BUFFER
			Special.Teleport:
				if !teleport_point.visible:
					teleport_point.visible = true
					teleport_point.global_position = global_position
				elif teleport_cooldown <= 0.0:
					global_position = teleport_point.global_position
					teleport_cooldown = TELEPORT_COOLDOWN

	if dashing:
		dash_time -= delta
		velocity = DASH_SPEED * direction
		
		if dash_time <= 0:
			dashing = false
			dash_time = DASH_TIME
			velocity = Vector2.ZERO
			DASH_SPEED = INIT_DASH_SPEED

	if hit_velocity.x > 0.0:
		hit_velocity.x -= 500.0 * delta * time_mult
		if hit_velocity.x < 0.0:
			hit_velocity.x = 0.0
	elif hit_velocity.x < 0.0:
		hit_velocity.x += 500.0 * delta * time_mult
		if hit_velocity.x > 0.0:
			hit_velocity.x = 0.0

	if hit_velocity.y > 0.0:
		hit_velocity.y -= 500.0 * delta * time_mult
		if hit_velocity.y < 0.0:
			hit_velocity.y = 0.0
	elif hit_velocity.y < 0.0:
		hit_velocity.y += 500.0 * delta * time_mult
		if hit_velocity.y > 0.0:
			hit_velocity.y = 0.0

	if parry_buffer > 0.0:
		gravity = 0.0
		velocity = Vector2.ZERO
		hit_velocity = Vector2.ZERO
	else:
		gravity = GRAVITY

	hit_area.position = direction * 100

	velocity *= time_mult

	move_and_slide()

	if is_on_ceiling() && hit_velocity.y < 0 && !hit_reversed:
		hit_velocity.y *= -1
		hit_reversed = true

	if is_on_floor() && hit_velocity.y > 0 && !hit_reversed:
		hit_velocity.y *= -1
		hit_reversed = true

	if is_on_ceiling() && hit_velocity.y < 0:
		hit_velocity.y = 0

	position += hit_velocity * delta * time_mult
	last_dir = direction
