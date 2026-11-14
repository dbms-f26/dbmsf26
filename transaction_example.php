<?php
// put this in your topstuff together with function get_conn()
function dumpSqlForDebugging($pdo, $sql, $params) {
    foreach ($params as $key => $value) {
        $placeholder = str_starts_with($key, ':') ? $key : ':' . $key;
        if (is_int($value) || is_float($value)) {
            $formatted = (string) $value;
        } else {
            $formatted = $pdo->quote((string) $value);
        }
        $sql = preg_replace('/' . preg_quote($placeholder, '/') . '\b/', $formatted, $sql);
    }
    echo htmlspecialchars($sql);
}

$pdo = get_conn();

try {
    // 1. Start the transaction
    $pdo->beginTransaction();

    // 2. Insert the main record (Parent)
    $userSql = "INSERT INTO users (first_name, last_name, email) 
                VALUES (:first_name, :last_name, :email)
                RETURNING user_id";
    $userData = [
        'first_name' => $_GET['first_name'] ?? null,
        'last_name'  => $_GET['last_name']  ?? null,
        'email'      => $_GET['email']      ?? null,
    ];

    // Uncomment the line below if your query fails and you want to test it in SQL:
    // dumpSqlForDebugging($pdo, $userSql, $userData);

    $userStmt = $pdo->prepare($userSql);
    $userStmt->execute($userData);

    // Grab the new user's ID to use as the Foreign Key
    $newRow = $stmt->fetch();
    $userId = $newRow['id'];


    // 3. Insert the child records
  
    // prepare the query once
    $childSql = "INSERT INTO dependents (user_id, first_name, last_name, birth_date) 
                     VALUES (:user_id, :fname, :lname, :bday)";
    $childStmt = $pdo->prepare($childSql);
    // iterate over the elements of the arrays holding child info
    for ($i = 0; $i < count($child_fname);; $i++) {
            // Skip completely blank rows if the user left extra form inputs empty
            if (!empty($child_fname[$i]){
            $childStmt->execute([
                'user_id' => $userId,
                'fname'   => $child_fname[$i] ?? null,
                'lname'   => $child_lname[$i] ?? null,
                'bday'    => $child_bday[$i]  ?? null,
            ]);
            }
    }

    // 4. Everything worked! Save all changes permanently.
    $pdo->commit();
    echo "<p>Success! User and dependents saved.</p>";

} catch (PDOException $e) {
    // 5. Something broke! Undo everything back to step 1.
    $pdo->rollBack();

    // Show the exact database error
    echo "<p>Database Error:" . htmlspecialchars($e->getMessage())."</p>";
}
