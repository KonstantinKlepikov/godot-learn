extends Area2D
signal hit


@export var speed = 1000 # player speed px/sec
var screen_size # game window size


# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size
	hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Check for input
	var velocity = Vector2.ZERO # player's movement vector
	if Input.is_action_just_released("move_right"):
		velocity.x += 1
	if Input.is_action_just_released("move_left"):
		velocity.x -= 1
	if Input.is_action_just_released("move_up"):
		velocity.y -= 1
	if Input.is_action_just_released("move_down"):
		velocity.y += 1
	
	# normalize velocity to prevent more 
	# faster move in diagonal direction and 
	# play animation after get input	
	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		# $ is shorthand for get_node(). So in 
		# the code above, $AnimatedSprite2D.play() 
		# is the same as 
		# get_node("AnimatedSprite2D").play()
		$AnimatedSprite2D.play()
	else:
		$AnimatedSprite2D.stop()

	# Move in the given direction.
	position += velocity * delta
	# prevent move from boardsr by using clamp()
	position.x = clamp(position.x, 0, screen_size.x)
	position.y = clamp(position.y, 0, screen_size.y)

	# Play the appropriate animation.
	if velocity.x != 0:
		$AnimatedSprite2D.animation = "walk"
		$AnimatedSprite2D.flip_v = false
		# See the note below about boolean assignment.
		$AnimatedSprite2D.flip_h = velocity.x < 0
	elif velocity.y != 0:
		$AnimatedSprite2D.animation = "up"
		$AnimatedSprite2D.flip_v = velocity.y > 0


func start(pos):
	position = pos
	show()
	$CollisionShape2D.disabled = false


func _on_body_entered(body):
	hide() # Player disappears after being hit.
	hit.emit()
	# Must be deferred as we can't change physics 
	# properties on a physics callback.
	# prevent doubling signal
	$CollisionShape2D.set_deferred("disabled", true)
