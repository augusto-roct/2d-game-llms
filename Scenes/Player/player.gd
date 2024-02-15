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
var is_player_listen
var is_talking = false
var player_listener
var text_talk = "Oi"
var messages

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
		
	$WriteHUD/WriteRichTextLabel.position = actually_position
	
	$WriteHUD/WriteRichTextLabel.position.y -= 50
	
	if list_players[0].position.x >= position.x:
		$WriteHUD/WriteRichTextLabel.position.x += 50
	else:
		$WriteHUD/WriteRichTextLabel.position.x -= $WriteHUD/WriteRichTextLabel.size.x - 10
	
	var limit_screen_size_y = $WriteHUD/WriteRichTextLabel.position.y + $WriteHUD/WriteRichTextLabel.size.y
	
	if $WriteHUD/WriteRichTextLabel.position.y >= screen_size.y: 
		$WriteHUD/WriteRichTextLabel.position.y -= $WriteHUD/WriteRichTextLabel.size.y + 50
	if $WriteHUD/WriteRichTextLabel.position.y <= 0: 
		$WriteHUD/WriteRichTextLabel.position.y += $WriteHUD/WriteRichTextLabel.size.y - 100


func talk(text, listener):
	if not is_talking:
		player_listener = listener
		is_talking = true
		
		var data = {
			"text": text,
			"system": system_prompt,
			"messages": messages,
			"parameters": {},
			"generation_config": {
				"candidate_count": 1,
				"max_output_tokens": 128,
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
	if response_code != 200:
		is_talking = false
		return
	
	messages = JSON.parse_string(body.get_string_from_utf8())
	
	text_talk = messages[-1]["content"]
	$WriteHUD/WriteRichTextLabel.text = text_talk
	
	$WriteHUD/WaitWriteTimer.start()
	$WriteHUD.show()


func start(pos, nick, prompt, is_listen):
	position = pos
	
	name_player = nick
	system_prompt = prompt.replace("{name_player}", name_player)
	$NamePlayerHUD/NameLabel.text = name_player
	
	$NamePlayerHUD/NameLabel.position = pos - center_player_size
	$NamePlayerHUD/NameLabel.show()
	
	$WriteHUD/WriteRichTextLabel.text = ""
	$WriteHUD.hide()
	
	is_player_listen = is_listen


func _on_wait_write_timer_timeout():	
	$WriteHUD/WriteRichTextLabel.text = ""
	$WriteHUD.hide()
	
	is_talking = false
	is_player_listen = true
	
	player_listener.is_player_listen = false
