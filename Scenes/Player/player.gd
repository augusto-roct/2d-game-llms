extends Area2D

@export var speed = 400
var screen_size
var is_animating = false
var select_movement
var player_size
var headers = ["Content-Type: application/json"]
var url = "http://127.0.0.1:8000/chat/completion"
var name_player
var system_prompt

func _ready():
	screen_size = get_viewport_rect().size
	player_size = $CollisionShape2D.shape.get_rect().size


func _process(delta):
	var velocity = Vector2.ZERO
	
	if not is_animating:
		is_animating = true
		$WaitAnimationTimer.start()
		select_movement = randi_range(0, 4)
	
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
	
	$HUD/NameLabel.position.y = position.y - (player_size.y/2 * 2.5) - 15
	$HUD/NameLabel.position.x = position.x - (player_size.x/2 * 2.5)
	
	if velocity.x < 0:
		$AnimatedSprite2D.animation = "left"
	elif velocity.x > 0:
		$AnimatedSprite2D.animation = "right"
	elif velocity.y < 0:
		$AnimatedSprite2D.animation = "up"
	elif velocity.y > 0:
		$AnimatedSprite2D.animation = "down"
	
	var data = {
	  "text": "Oi",
	  "system": system_prompt,
	  "parameters": {},
	  "generation_config": {
		"candidate_count": 1,
		"max_output_tokens": 512,
		"temperature": 0.3,
		"top_p": 0.1,
		"top_k": 1
	  },
	  "safety_settings": {
		"HARM_CATEGORY_HARASSMENT": "BLOCK_NONE",
		"HARM_CATEGORY_HATE_SPEECH": "BLOCK_NONE",
		"HARM_CATEGORY_SEXUALLY_EXPLICIT": "BLOCK_NONE",
		"HARM_CATEGORY_DANGEROUS_CONTENT": "BLOCK_NONE"
	  }
	}
	var payload = JSON.stringify(data)
	
	$HTTPRequest.request(url, headers, HTTPClient.METHOD_POST, payload)


func _on_wait_animation_timer_timeout():
	is_animating = false


func _on_http_request_completed(result, response_code, headers, body):
	var json = JSON.parse_string(body.get_string_from_utf8())
	print(json)


func start(pos, nick, prompt):
	position = pos
	
	name_player = nick
	system_prompt = prompt.replace("{name_player}", name_player)
	$HUD/NameLabel.text = name_player
	
	$HUD/NameLabel.position = pos
	$HUD/NameLabel.position.y = pos.y - (player_size.y * 2.5)
	$HUD/NameLabel.position.x = pos.x - (player_size.x * 2.5)
	$HUD/NameLabel.show()
	
	system_prompt = prompt
