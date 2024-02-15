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
var center_player_size
var actually_position
var list_players

func _ready():
	screen_size = get_viewport_rect().size
	player_size = $CollisionShape2D.shape.get_rect().size
	
	center_player_size = Vector2((player_size.x/2 * 2.5), (player_size.y/2 * 2.5))


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
	position = position.clamp(center_player_size, (screen_size - center_player_size))
	
	actually_position = position - center_player_size
	
	$NamePlayerHUD/NameLabel.position = actually_position
	$NamePlayerHUD/NameLabel.position.y -= 15
	
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
	
	#$HTTPRequest.request(url, headers, HTTPClient.METHOD_POST, payload)

func _on_wait_animation_timer_timeout():
	is_animating = false


func _on_http_request_completed(result, response_code, headers, body):
	var messages = JSON.parse_string(body.get_string_from_utf8())
	
	$WriteHUD/WriteRichTextLabel.text = messages[-1]["content"]
	
	$WriteHUD/WriteRichTextLabel.position = actually_position
	
	$WriteHUD/WriteRichTextLabel.position.y -= 100
	
	if list_players[0].position.x >= position.x:
		$WriteHUD/WriteRichTextLabel.position.x += 50
	else:
		$WriteHUD/WriteRichTextLabel.position.x -= $WriteHUD/WriteRichTextLabel.size.x - 10
	
	var limit_screen_size_y = $WriteHUD/WriteRichTextLabel.position.y + $WriteHUD/WriteRichTextLabel.size.y
	
	if $WriteHUD/WriteRichTextLabel.position.y >= screen_size.y: 
		$WriteHUD/WriteRichTextLabel.position.y -= $WriteHUD/WriteRichTextLabel.size.y + 100
	if $WriteHUD/WriteRichTextLabel.position.y <= 0: 
		$WriteHUD/WriteRichTextLabel.position.y += $WriteHUD/WriteRichTextLabel.size.y + 100

	$WriteHUD.show()
	
	$WriteHUD/WaitWriteTimer.start()


func start(pos, nick, prompt):
	position = pos
	
	name_player = nick
	system_prompt = prompt.replace("{name_player}", name_player)
	$NamePlayerHUD/NameLabel.text = name_player
	
	$NamePlayerHUD/NameLabel.position = pos - center_player_size
	$NamePlayerHUD/NameLabel.show()
	
	system_prompt = prompt


func _on_wait_write_timer_timeout():
	$WriteHUD/WriteRichTextLabel.text = ""
	$WriteHUD.hide()
