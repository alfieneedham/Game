extends CharacterBody2D

# TODO:
	# Add jump buffering. Thinking I should add an area 2d below the player which just resets their jumps when comes into contact with the ground.
	# Add wall slide and jump. This jump should only activate when a variable is true, should give them a horizontal impulse away from the wall and still allow a double jump if unlocked.
	# Make it so that if the player clips the edge of a wall when jumping, the player is pushed to the side without losing and vertical speed. Probably done using several area 2d's above player.
	# Then we can move onto weapon. First, add the lmb main attack, simply dealing damage to enemies in front. Then, onto rmb special. This throws weapon away from player, dealing decreased damage but increased knockback.
	# If the special comes into contact with an 'anchor point', the players velocity is cancelled before they are pulled towards the anchor point with a constant velocity.

# Can be changed:
const MAX_WALK_SPEED = 100
const ACCELERATION = 20
const MAX_FALL_SPEED = 450
const GRAVITY = 12
const JUMP = 270
const COYOTE_TIMING = 10
var maxJumps = 2

# Cannot be changed:
var coyoteTimingOut = false
var numJumps = maxJumps
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
	if Input.is_action_just_pressed("jump") and numJumps > 0:
		falling = false
		velocity.y = -JUMP
		numJumps -= 1
	if  Input.is_action_just_released("jump") and falling == false:
		falling = true
		velocity.y *= 0.5
	if velocity.y >= 0:
		falling = true
	if is_on_floor():
		numJumps = maxJumps
		falling = false
	# Handles coyote timing:
		coyoteTimingOut = false
		coyoteTimingFrames = COYOTE_TIMING
	if not is_on_floor() and coyoteTimingFrames > 0:
		coyoteTimingFrames -= 1
	if coyoteTimingFrames == 0 and coyoteTimingOut == false and numJumps == maxJumps:
		numJumps -= 1
		coyoteTimingOut = true

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
