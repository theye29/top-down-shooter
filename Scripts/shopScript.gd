extends Control

@onready var player = $"../../Player"
@onready var clopen_button = $Panel/Clopen
@onready var money_label = $Panel/MoneyCount
@onready var ammo_label = $"../HudSelf/AmmoCount"

#Shop buttons
@onready var health_button = $Panel/Refills/RefillHealth
@onready var shield_button = $Panel/Refills/RefillShield
@onready var dont_button = $Panel/Refills/DontPress
@onready var damage_button = $Panel/Upgrades/DamageButton
@onready var firerate_button = $Panel/Upgrades/FirerateButton
@onready var reload_button = $Panel/Upgrades/ReloadButton
@onready var walkspeed_button = $Panel/Upgrades/WalkButton
@onready var piercing_button = $Panel/Upgrades/PiercingButton
@onready var maxammo_button = $Panel/Upgrades/MaxAmmoButton

@onready var purchase_sound = $PurchaseSound
@onready var safezone : SafeZone = get_node("../../Map/Safezone/AreaSafezone")

var health_price
var dont_price
var shield_price
var damage_price
var firerate_price
var reload_price
var walkspeed_price
var piercing_price
var maxammo_price

var is_open = true
var dontpressed = false

func _ready() -> void:
	safezone.player_enter_safezone.connect(show_shop)
	safezone.player_exit_safezone.connect(hide_shop)


func _process(_delta: float) -> void:
	pass



func show_shop():
	toggle_shop()
	player.weapon.can_shoot = false
	visible = true
	
func hide_shop():
	if is_open:
		toggle_shop()
	player.weapon.can_shoot = true
	visible = false
	
func _on_clopen_pressed() -> void:
	toggle_shop()
 
func reload_shop():
	var healthcolor
	var shieldcolor
	var dontcolor
	
	money_label.text = "$" + str(player.money)

	#upgrades prices
	damage_price = round(60 * pow(1.4, player.damage_level) / 10) * 10
	firerate_price = round(100 * pow(1.6, player.firerate_level) / 10) * 10
	reload_price = round(70 * pow(1.45, player.reload_level) / 10) * 10
	walkspeed_price = round(40 * pow(1.35, player.walkspeed_level) / 10) * 10
	piercing_price = round(150 * pow(1.6, player.piercing_level) / 10) * 10
	maxammo_price = round(70 * pow(1.4, player.ammo_level) / 10) * 10
	
	var damages = player.get_upgrade_type("damage")
	var firerates = player.get_upgrade_type("firerate")
	var reloads = player.get_upgrade_type("reload")
	var walkspeeds = player.get_upgrade_type("walkspeed")
	var piercings = player.get_upgrade_type("piercing")
	var maxammos = player.get_upgrade_type("ammo")
	
	upgrade_button(damage_button, player.damage_level, damage_price, 12, "Damage ( %d -> %d )  -  " % [damages[0], damages[1]])
	upgrade_button(firerate_button, player.firerate_level, firerate_price, 8, "Firerate ( %.2f -> %.2f )  -  " % [firerates[0], firerates[1]])
	upgrade_button(reload_button, player.reload_level, reload_price, 8, "Reload ( %.2f -> %.2f)  -  " % [reloads[0], reloads[1]])
	upgrade_button(walkspeed_button, player.walkspeed_level, walkspeed_price, 6, "Walkspeed ( speed / %.2f -> %.2f )  -  " % [walkspeeds[0], walkspeeds[1]])
	upgrade_button(piercing_button, player.piercing_level, piercing_price, 5, "Piercing ( %d -> %d )  -  " % [piercings[0], piercings[1]])
	upgrade_button(maxammo_button, player.ammo_level, maxammo_price, 10, "Max ammo ( %d -> %d )  -  " % [maxammos[0], maxammos[1]])
	
	#Refill prices
	shield_price = player.max_shield
	shield_button.text = "Buy Shield  -  $" + str(shield_price)
	shield_button.disabled = false
	
	health_price = (player.max_hp - player.hp) * 2
	health_button.text = "Refill Health  -  $" + str(health_price)
	health_button.disabled = false
	
	dont_price = 67
	dont_button.text = "Dont buy this  -  $" + str(dont_price)
	dont_button.disabled = false
	
	#Health
	if health_price == 0:
		healthcolor = Color.RED
		health_button.disabled = true
		health_button.text = "Refill Health  -  FULL"
	elif player.money < health_price:
		healthcolor = Color.RED
		health_button.disabled = true
		health_button.text = "Refill Health  -  $" + str(health_price)
	else:
		healthcolor = Color.WHITE
	
	#Shield
	if player.shield == player.max_shield:
		shieldcolor = Color.RED
		shield_button.disabled = true
		shield_button.text = "Buy Shield  -  FULL"
	elif player.money < shield_price:
		shieldcolor = Color.RED
		shield_button.disabled = true
		shield_button.text = "Buy Shield  -  $" + str(shield_price)
	else:
		shieldcolor = Color.WHITE
	
	if dontpressed:
		dontcolor = Color.RED
		dont_button.text = "I warned you"
		dont_button.disabled = true
	elif dont_price < player.money:
		dontcolor = Color.WHITE
		dont_button.disabled = false
	elif player.money < dont_price:
		dontcolor = Color.RED
		dont_button.disabled = true

	
	button_color(health_button, healthcolor)
	button_color(shield_button, shieldcolor)
	button_color(dont_button, dontcolor)
	

func button_color(button, color):
	button.add_theme_color_override("font_color", color)
	button.add_theme_color_override("font_hover_color", color)
	button.add_theme_color_override("font_pressed_color", color)
	button.add_theme_color_override("font_focus_color", color)
	button.add_theme_color_override("font_disabled_color", color)
	

func upgrade_button(button, level, price, maxlevel, text):
	if level == maxlevel:
		button.text = "FULL"
		button_color(button, Color.GREEN)
		button.disabled = true
	else:
		button.text = text + "$" + str(int(price))
		if player.money < price:
			button_color(button, Color.RED)
			button.disabled = true
		else:
			button_color(button, Color.WHITE)
			button.disabled = false
			



func toggle_shop():
	reload_shop()
	var tween = create_tween()
	if is_open:
		tween.tween_property(self, "anchor_bottom", 0, 0.3)
		tween.tween_property(self, "anchor_top", 0, 0.3)
		
	else:
		tween.tween_property(self, "anchor_top", 0.75, 0.3)
		
	is_open = !is_open
	

func buy_item(itemprice):
	player.money -= int(itemprice)
	player.money_count.text = "$" + str(player.money)
	reload_shop()
	var sfx_shop = purchase_sound.duplicate() 
	add_child(sfx_shop)
	sfx_shop.play()
	
func _on_refill_health_pressed() -> void:
	player.hp += health_price / 2
	player.healthbar.value = player.hp
	buy_item(health_price)

func _on_refill_shield_pressed() -> void:
	player.shield = player.max_shield
	player.shieldbar.value = player.shield
	buy_item(shield_price)

func _on_damage_button_pressed() -> void:
	player.upgrade_damage()
	buy_item(damage_price)


func _on_firerate_button_pressed() -> void:
	player.upgrade_firerate()
	buy_item(firerate_price)


func _on_reload_button_pressed() -> void:
	player.upgrade_reload()
	buy_item(reload_price)


func _on_walk_button_pressed() -> void:
	player.upgrade_walkspeed()
	buy_item(walkspeed_price)


func _on_piercing_button_pressed() -> void:
	player.upgrade_piercing()
	buy_item(piercing_price)


func _on_max_ammo_button_pressed() -> void:
	player.upgrade_ammo()
	buy_item(maxammo_price)


func _on_reload_pressed() -> void:
	if player.weapon and not player.weapon.reload:
		player.weapon.reload = true


func _on_dont_press_pressed() -> void:
	dontpressed = true
	player.money -= int(dont_price)
	player.money_count.text = "$" + str(player.money)
	reload_shop()
	var sfx_shop = $Muehehehehe.duplicate() 
	add_child(sfx_shop)
	sfx_shop.play()
	$"../../Wavemanager".wave_number = 66
