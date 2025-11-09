extends Control

@export_file("*.csv") var csv_file: String
@export var translate_empty_only: bool = true

const API_KEY = "c48a78eb-8648-4d93-b606-34068169badb:fx"

var file = null
var csv = []


func _ready():
	# run the translate method when _ready is done
	ready.connect(translate.bind())


func translate():
	$Status.text = "Reading CSV " + csv_file
	file = FileAccess.open(csv_file, FileAccess.READ_WRITE)
	while !file.eof_reached():
		var csv_row = file.get_csv_line()
		if !file.eof_reached():
			csv.append(csv_row)
	
	# Grab the alternative language column identifiers
	var csv_keys = csv.pop_front()
	
	# Loop through the file and translate 
	for row in csv:
		for index in range(2, 11):
			if row[index] == "" or not translate_empty_only:
				$Status.text = "Translating " + row[0] + ":" + csv_keys[index] + " " + row[index]
				request_translation(row[1], csv_keys[index])
				
				# Collect response data
				var response = await $HTTPRequest.request_completed
				var result = response[0]
				var status_code = response[1]
				var headers = response[2]
				var body = JSON.parse_string(response[3].get_string_from_utf8())
				
				# Save translated text to CSV object
				if status_code == 200:
					var translated_text = body["translations"][0]["text"]
					row[index] = translated_text
	# Rewrite the CSV from the beginning
	file.seek(0)
	file.store_csv_line(csv_keys)
	for row in csv:
		file.store_csv_line(row)
	file.close()
	$Status.text = "Completed"


func request_translation(english_text: String, language_tag: String):
	var url = "https://api-free.deepl.com/v2/translate"
	var json = JSON.stringify({
		"text": [english_text],
		"source_lang": "EN",
		"target_lang": language_tag.capitalize()
	})
	var headers = [
		"Authorization: DeepL-Auth-Key " + API_KEY,
		"Content-Type: application/json"
	]
	$HTTPRequest.request(url, headers, HTTPClient.METHOD_POST, json)
