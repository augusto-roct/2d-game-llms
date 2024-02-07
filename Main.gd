extends Node2D


func _ready():
	$Joseph.start(Vector2(1200, 80), "Joseph")
	$Will.start(Vector2(80, 640), "Will")
	


func _process(delta):
	pass
