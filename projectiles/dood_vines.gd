extends Projectile

var master = true
var child
var shot = false

func _ready():
	$Vines.play()
	dupe()

func _process(delta):
#	$Dev.text = str($Sprite.frame != 8)
	if $Sprite.frame == 2:
		$CollisionShape2D.disabled = false
	elif $Sprite.frame == 4:
		$CollisionShape2D.disabled = true

func dupe():
	current_speed = 0
	$Sprite.play()
	if master:
#		var next_vine = Global.spawn_projectile(shooter,"dood_vines",position+(direction*10),direction,true)
		child = load("res://projectiles/dood_vines.tscn").instantiate()
		child.shooter = shooter
		child.position = position+(direction*30)
		child.direction = direction
		child.player_bullet = player_bullet
		child.damage = damage
		child.master = false
		
		Global.spawn_in(child)
	
	await get_tree().create_timer(0.2).timeout

	if is_instance_valid(child) and $VisibleOnScreenNotifier2D.is_on_screen():
		child.damage = damage
		child.master = true
		child.dupe()

func affect(victim:Object):
	super(victim)

func _on_sprite_animation_finished():
	Global.kill(self)
