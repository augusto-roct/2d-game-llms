extends Node2D


var prompt_farmer = FileAccess.open("./Scenes/Main/prompts/farmer.txt", FileAccess.READ).get_as_text()

func _ready():
	$Joseph.start(Vector2(1200, 80), "Joseph", prompt_farmer, false)
	$Will.start(Vector2(80, 640), "Will", "", true)
	


func _process(delta):
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
		
