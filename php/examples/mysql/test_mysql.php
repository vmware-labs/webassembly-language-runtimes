<?php
  $user = getenv('TEST_USER') ? getenv('TEST_USER') : 'test_user';
  $password = getenv('TEST_PASSWORD') ? getenv('TEST_PASSWORD') : 'test_password';
  $host = getenv('TEST_HOST') ? getenv('TEST_HOST') : '127.0.0.1';
  $port = getenv('TEST_PORT') ? getenv('TEST_PORT') : '3306';
  $db_name = getenv('TEST_DB') ? getenv('TEST_DB') : 'test_db';
  $connection_string = "mysql:host=$host;port=$port;dbname=$db_name";

  # Connect to the database
  print("\n");
  print("Connecting with connection_string=$connection_string, user=$user, password=$password...\n\n");
  $conn = new PDO($connection_string, $user, $password);

  # Show all tables
  $tableList = array();
  $result = $conn->query("SHOW TABLES");
  while ($row = $result->fetch(PDO::FETCH_NUM)) {
      $tableList[] = $row[0];
  }
  print_r($tableList);


  # Create a new table
  print("\n");
  $table_name="Sample";
  print("Creating table '$table_name'...\n");
  $sql_create_sample = "
    DROP TABLE IF EXISTS $table_name;
    CREATE TABLE $table_name(
      id INT(2) PRIMARY KEY NOT NULL AUTO_INCREMENT,
      name VARCHAR(30) NOT NULL,
      description VARCHAR(30)
    )";
  $conn->exec($sql_create_sample);
  print("Table '$table_name' created!\n");


  # Insert values into table
  print("\n");
  print("Inserting three records into '$table_name'...\n");
  $sql_insert_sample = "
    INSERT INTO Sample(Name, Description) VALUES('First', 'Original sample');
    INSERT INTO Sample(Name, Description) VALUES('Second', 'Secondary sample');
    INSERT INTO Sample(Name) VALUES('Third');
  ";
  $conn->exec($sql_insert_sample);
  print("Inserted rows into $table_name!\n");


  # Select values from table
  print("\n");
  print("Selecting all from '$table_name'...\n");
  $query = $conn->prepare("SELECT * FROM $table_name");
  $query->execute();

  $selection_result = $query->fetchAll(\PDO::FETCH_ASSOC);
  print_r($selection_result);
?>
