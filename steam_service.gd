extends Node

signal log_message(message)
signal tags_set(tags)

const STEAM_WORKSHOP_AGREEMENT_URL: String = "https://steamcommunity.com/sharedfiles/workshoplegalagreement"

var steam_app_id: int = -1
var steam_workshop_tags: Array = []


func initialize() -> void:
	var init_result: Dictionary = Steam.steamInitEx(0, true)
	if init_result["status"] == 0:
		log_message.emit("Steam initialization OK!")
	else:
		log_message.emit("Steam could not initialize: %s" % str(init_result))

	var game_install_directory := get_game_dir()

	var file = FileAccess.open(game_install_directory + "/steam_data.json", FileAccess.READ)
	if file == null:
		log_message.emit("Can't open steam_data file %s. Please make sure the file exists and is valid. Error message: %s" % [
			(game_install_directory + "/steam_data.json"), FileAccess.get_open_error()
			])
	else:
		var file_content: Dictionary = JSON.parse_string(file.get_as_text())
		if !file_content.has("app_id"):
			log_message.emit("The steam_data file does not contain an app ID, mod uploading will not work.")
			return
		if file_content.has("tags"):
			steam_workshop_tags = file_content.tags as Array
			tags_set.emit(steam_workshop_tags)
		steam_app_id = file_content.app_id as int


func get_game_dir() -> String:
	var game_install_directory := OS.get_executable_path().get_base_dir()
	if OS.get_name() == "OSX":
		game_install_directory = game_install_directory.get_base_dir().get_base_dir()
		if game_install_directory.ends_with(".app"):
			game_install_directory = game_install_directory.get_base_dir()
	if OS.has_feature("editor"):
		game_install_directory = "res://"
	return game_install_directory
