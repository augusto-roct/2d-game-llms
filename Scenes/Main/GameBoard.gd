extends Node2D





func _ready():
	$Joseph.start(Vector2(1200, 80), "Joseph", false)
	$Will.start(Vector2(80, 640), "Will", true)
	


func _process(delta):
	if $Joseph.is_stop:
		print($Joseph.messages)
		get_tree().paused = true
		
	$Joseph.list_players = [
		{
			"name": "Will",
			"position": $Will.position
		}
	]
	
	$Will.list_players = [
		{
			"name": "Joseph",
			"position": $Joseph.position
		}
	]
	
	if not $Joseph.is_talking and not $Joseph.is_player_listen and $Will.is_player_listen:
		$Joseph.talk($Will.text_talk, $Will)
		
	elif not $Will.is_talking and not $Will.is_player_listen and $Joseph.is_player_listen:
		$Will.talk($Joseph.text_talk, $Joseph)
		
