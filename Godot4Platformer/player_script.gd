extends CharacterBody2D

# Can be changed:
const MAX_WALK_SPEED = 100
const ACCELERATION = 20
const MAX_FALL_SPEED = 450
const GRAVITY = 5
const JUMP = 275
const COYOTE_TIMING = 10
const JUMP_BUFFER = 20

# Cannot be changed:
var coyoteTimingFrames = COYOTE_TIMING
var jumpBufferFrames = 0
var falling = true
var canJump = true

func _ready():
	pass
	
func get_walk_input():
	var direction = 0
	if Input.is_action_pressed("move_left"):
		direction -= 1
	if Input.is_action_pressed("move_right"):
		direction += 1
	walk(direction)
		
func walk(direction):
	if direction != 0:
		velocity.x += ACCELERATION * direction
		if abs(velocity.x) > MAX_WALK_SPEED:
			velocity.x = MAX_WALK_SPEED * direction
	elif velocity.x > 0:
		velocity.x -= ACCELERATION
	elif velocity.x < 0:
		velocity.x += ACCELERATION
	elif abs(velocity.x) < ACCELERATION:
		velocity.x = 0

func jump():
	# Handles jump and falling state:
	if Input.is_action_just_pressed("jump") and canJump == true:
		velocity.y -= JUMP
		falling = false
		canJump = false
	if  Input.is_action_just_released("jump"):
		falling = true
		velocity.y *= 0.5
	if velocity.y >= 0 and coyoteTimingFrames == 0:
		falling = true
	if is_on_floor():
		falling = false
	# Handles coyote timing:
		coyoteTimingFrames = COYOTE_TIMING
	if not is_on_floor() and coyoteTimingFrames > 0:
		coyoteTimingFrames -= 1
	if coyoteTimingFrames == 0:
		canJump = false
	else:
		canJump = true

func gravity():
	if velocity.y < MAX_FALL_SPEED and not is_on_floor():
		if falling == true:
			velocity.y += GRAVITY * 1.5
		else:
			velocity.y += GRAVITY
		if velocity.y > MAX_FALL_SPEED:
			velocity.y = MAX_FALL_SPEED

func _process(_delta):
	get_walk_input()
	gravity()
	jump()
	move_and_slide()
	print(falling)
