<?php
// SIMPLE API FOR TESTING
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');

$action = $_GET['action'] ?? '';

if ($action === 'test') {
    echo json_encode([
        'status' => 'success',
        'message' => 'PIWZ HUNTER API is running',
        'version' => '2.0',
        'timestamp' => time()
    ]);
    exit;
}

if ($action === 'register') {
    $deviceId = $_POST['device_id'] ?? 'DEV-' . uniqid();
    
    // Log device
    file_put_contents('logs.txt', date('Y-m-d H:i:s') . " - Device registered: $deviceId\n", FILE_APPEND);
    
    echo json_encode([
        'status' => 'success',
        'device_id' => $deviceId,
        'command' => 'wait'
    ]);
    exit;
}

// Default response
echo json_encode([
    'status' => 'error',
    'message' => 'Invalid action',
    'available_actions' => ['test', 'register']
]);
?>
