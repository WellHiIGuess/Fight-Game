extends Player


@export var player_num: String

const SPEED = 500.0
const DASH_SPEED = 2000.0
const JUMP_VELOCITY = -600.0
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

var direction: Vector2

var hit_velocity: Vector2

@export var sprite: Sprite2D
@export var spawn_point: Node2D

const SPRITE_SQUASH = 0.1
var sprite_width: float

@export var copies: Node2D
var copy = 1
var copy_wait = COPY_WAIT

@export var hit_area: HitArea

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var can_dash = false
var dashing = false
var dash_time = DASH_TIME
var dash_stun = 0.0
var dash_dir = Vector2.ZERO
var dash_buffered = false

@export var wall_climb: WallClimb
var climbing_wall = false

func _ready():
	sprite_width = sprite.scale.x

	var json_string = "[0, 1, 2, 3, 4, 5]"
	var json = JSON.new()

	# Parse the JSON string
	var result = json.parse(json_string)

	if result == OK:
		# Successfully parsed, access the data
		var data = json.get_data()

		print(data[1])
	else:
		print("Failed to parse JSON")

func respawn():
	position = spawn_point.position
	dashing = false
	can_dash = false
	dash_stun = 0.0
	dash_buffered = false
	hit_velocity = Vector2.ZERO

func _process(delta):
	if can_dash:
		sprite.modulate.b = 0.0
		sprite.modulate.g = 0.0
	else:
		sprite.modulate.b = 1.0
		sprite.modulate.g = 1.0


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
	if not is_on_floor():
		velocity.y += gravity * delta

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	direction = Input.get_vector("Left" + player_num, "Right" + player_num, "Up" + player_num, "Down" + player_num)
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
	elif Input.is_action_just_pressed("Dash" + player_num) && (dash_time <= DASH_BUFFER) && dashing && !dash_buffered:
		dash_buffered = true
		

	if dashing:
		dash_time -= delta
		velocity = DASH_SPEED * direction
		
		if dash_time <= 0:
			dashing = false
			dash_time = DASH_TIME
			velocity = Vector2.ZERO

	if hit_velocity.x > 0.0:
		hit_velocity.x -= 500.0 * delta
		if hit_velocity.x < 0.0:
			hit_velocity.x = 0.0
	elif hit_velocity.x < 0.0:
		hit_velocity.x += 500.0 * delta
		if hit_velocity.x > 0.0:
			hit_velocity.x = 0.0

	if hit_velocity.y > 0.0:
		hit_velocity.y -= 500.0 * delta
		if hit_velocity.y < 0.0:
			hit_velocity.y = 0.0
	elif hit_velocity.y < 0.0:
		hit_velocity.y += 500.0 * delta
		if hit_velocity.y > 0.0:
			hit_velocity.y = 0.0

	hit_area.position = direction * 100

	for i in range(0, get_slide_collision_count()):
		var collision = get_slide_collision(i)

		if collision.get_collider() != null && collision.get_collider() is RigidBody2D && is_on_wall():
			collision.get_collider().linear_velocity.x = velocity.x

	move_and_slide()

	position += hit_velocity * delta
