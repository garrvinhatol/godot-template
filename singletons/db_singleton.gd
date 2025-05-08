extends Node

var database: SQLite

func _ready():
	# Initialize the database connection
	database = SQLite.new()
	database.path = "res://db_related/pb_data/data.db"
	var db_opened = database.open_db()

	if db_opened:
		print("Database opened successfully")
		# Get all tables in the database
		var tables = get_all_tables()

		# Process each table
		for table_name in tables:
			var columns = get_table_columns(table_name)
			print("Table: ", table_name)
			print("Columns: ", columns)
	else:
		print("Failed to open database: ", database.error_message)

# Function to retrieve all tables from the database
func get_all_tables() -> Array:
	# Query to get all table names from sqlite_master
	var query = "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%';"
	var success = database.query(query)

	var tables = []
	if success:
		# Extract table names from query result
		for row in database.query_result:
			tables.append(row["name"])
	else:
		print("Failed to get tables: ", database.error_message)

	return tables

# Function to retrieve all columns for a specific table
func get_table_columns(table_name: String) -> Array:
	# Query to get column info from PRAGMA table_info
	var query = "PRAGMA table_info(%s);" % table_name
	var success = database.query(query)

	var columns = []
	if success:
		# Extract column details from query result
		for row in database.query_result:
			columns.append({
				"name": row["name"],
				"type": row["type"],
				"notnull": row["notnull"],
				"default_value": row["dflt_value"],
				"primary_key": row["pk"]
			})
	else:
		print("Failed to get columns for table %s: %s" % [table_name, database.error_message])
	return columns
