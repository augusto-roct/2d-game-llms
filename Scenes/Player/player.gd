extends Area2D

@export var speed = 400
var screen_size
var is_animating = false
var select_movement


func _ready():
	screen_size = get_viewport_rect().size


func _process(delta):
	var velocity = Vector2.ZERO
	
	if not is_animating:
		is_animating = true
		$WaitAnimationTimer.start()
		select_movement = randi_range(0, 4)
		
	var player_size = $CollisionShape2D.shape.get_rect().size
	
	if select_movement == 0:
		velocity.y -= 1
	elif select_movement == 1:
		velocity.y += 1
	elif select_movement == 2:
		velocity.x -= 1
	elif select_movement == 3:
		velocity.x += 1
		
	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		$AnimatedSprite2D.play()
	else:
		if not $AnimatedSprite2D.is_playing():
			$AnimatedSprite2D.play()
		
		$AnimatedSprite2D.animation = "idle"
	
	
	position += velocity * delta
	position = position.clamp(player_size/2 * 2.5, (screen_size - (player_size/2 * 2.5)))
	
	if velocity.x < 0:
		$AnimatedSprite2D.animation = "left"
	elif velocity.x > 0:
		$AnimatedSprite2D.animation = "right"
	elif velocity.y < 0:
		$AnimatedSprite2D.animation = "up"
	elif velocity.y > 0:
		$AnimatedSprite2D.animation = "down"


func _on_wait_animation_timer_timeout():
	is_animating = false