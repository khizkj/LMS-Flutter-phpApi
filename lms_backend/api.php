<?php
session_start();
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS, PUT, DELETE");
header("Content-Type: application/json");

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    exit;
}

// === DB CONNECTION ===
$host = "localhost";
$user = "root";
$pass = "";
$db   = "lmsvision";

$conn = new mysqli($host, $user, $pass, $db);
if ($conn->connect_error) {
    http_response_code(500);
    echo json_encode(["status" => "error", "message" => "Database connection failed"]);
    exit;
}

// Set charset
$conn->set_charset("utf8");

// === HELPER FUNCTIONS ===
function get_input() {
    if (!empty($_POST)) return $_POST;
    $raw = file_get_contents("php://input");
    if ($raw) {
        $json = json_decode($raw, true);
        if (is_array($json)) return $json;
    }
    return [];
}

function clean($v) {
    return trim((string)$v);
}

function send_json(array $arr) {
    echo json_encode($arr);
    exit;
}

function public_user(?array $row) {
    if (!$row) return null;
    unset($row['password']);
    return $row;
}

// === ROUTER ===
$action = $_GET['action'] ?? '';

switch ($action) {
    // === USER REGISTRATION & LOGIN ===
    case 'register':
        $data = get_input();
        $username = clean($data['username'] ?? '');
        $email = clean($data['email'] ?? '');
        $password = $data['password'] ?? '';

        if ($username === '' || $email === '' || $password === '') {
            send_json(["status" => "error", "message" => "All fields are required"]);
        }
        if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
            send_json(["status" => "error", "message" => "Invalid email format"]);
        }
        if (strlen($password) < 6) {
            send_json(["status" => "error", "message" => "Password must be at least 6 characters"]);
        }

        // Check if email already exists
        $check = $conn->prepare("SELECT id FROM users WHERE email = ?");
        $check->bind_param("s", $email);
        $check->execute();
        $check->store_result();
        if ($check->num_rows > 0) {
            send_json(["status" => "error", "message" => "Email already exists"]);
        }

        $hashed = password_hash($password, PASSWORD_DEFAULT);
        $stmt = $conn->prepare("INSERT INTO users (username, email, password, created_at) VALUES (?, ?, ?, NOW())");
        $stmt->bind_param("sss", $username, $email, $hashed);
        
        if ($stmt->execute()) {
            send_json(["status" => "success", "message" => "User registered successfully"]);
        } else {
            send_json(["status" => "error", "message" => "Registration failed: " . $conn->error]);
        }

    case 'login':
        $data = get_input();
        $email = clean($data['email'] ?? '');
        $password = $data['password'] ?? '';

        if ($email === '' || $password === '') {
            send_json(["status" => "error", "message" => "Email and password are required"]);
        }

        $stmt = $conn->prepare("SELECT * FROM users WHERE email = ?");
        $stmt->bind_param("s", $email);
        $stmt->execute();
        $res = $stmt->get_result();
        $user = $res->fetch_assoc();

        if ($user && password_verify($password, $user['password'])) {
            $_SESSION['user_id'] = $user['id'];
            send_json([
                "status" => "success",
                "message" => "Login successful",
                "user" => public_user($user),
                "session_id" => session_id()
            ]);
        } else {
            send_json(["status" => "error", "message" => "Invalid email or password"]);
        }

    case 'logout':
        $_SESSION = [];
        if (session_id() || isset($_COOKIE[session_name()])) {
            setcookie(session_name(), '', time() - 3600, '/');
        }
        session_destroy();
        send_json(["status" => "success", "message" => "Successfully logged out"]);

    case 'session_check':
        if (!isset($_SESSION['user_id'])) {
            send_json(["status" => "error", "message" => "Not logged in"]);
        }
        $uid = $_SESSION['user_id'];
        $stmt = $conn->prepare("SELECT * FROM users WHERE id = ?");
        $stmt->bind_param("i", $uid);
        $stmt->execute();
        $res = $stmt->get_result();
        $user = $res->fetch_assoc();
        send_json(["status" => "success", "user" => public_user($user)]);

    // === USER MANAGEMENT ===
    case 'get_users':
        $res = $conn->query("SELECT id, username, email, created_at FROM users ORDER BY id DESC");
        $users = [];
        while ($row = $res->fetch_assoc()) {
            $users[] = $row;
        }
        send_json(["status" => "success", "users" => $users]);

    case 'delete_user':
        $data = get_input();
        $id = $data['id'] ?? '';
        if (!$id || !is_numeric($id)) {
            send_json(["status" => "error", "message" => "Valid user ID is required"]);
        }
        
        // First delete related records in course_progress
        $stmt1 = $conn->prepare("DELETE FROM course_progress WHERE user_id = ?");
        $stmt1->bind_param("i", $id);
        $stmt1->execute();
        
        // Then delete the user
        $stmt = $conn->prepare("DELETE FROM users WHERE id = ?");
        $stmt->bind_param("i", $id);
        if ($stmt->execute()) {
            if ($stmt->affected_rows > 0) {
                send_json(["status" => "success", "message" => "User deleted successfully"]);
            } else {
                send_json(["status" => "error", "message" => "User not found"]);
            }
        } else {
            send_json(["status" => "error", "message" => "Failed to delete user: " . $conn->error]);
        }

    // === COURSE MANAGEMENT ===
    case 'add_course':
        $title = $_POST['title'] ?? '';
        $desc = $_POST['description'] ?? '';
        $tags = $_POST['tags'] ?? '';
        
        if ($title === '' || $desc === '') {
            send_json(["status" => "error", "message" => "Title and description are required"]);
        }

        $imageName = null;
        if (isset($_FILES['image']) && $_FILES['image']['error'] === UPLOAD_ERR_OK) {
            $uploadDir = __DIR__ . "/uploads/";
            if (!is_dir($uploadDir)) {
                if (!mkdir($uploadDir, 0777, true)) {
                    send_json(["status" => "error", "message" => "Failed to create upload directory"]);
                }
            }
            
            $allowedTypes = ['image/jpeg', 'image/png', 'image/gif', 'image/webp'];
            $fileType = $_FILES['image']['type'];
            if (!in_array($fileType, $allowedTypes)) {
                send_json(["status" => "error", "message" => "Invalid image type. Only JPEG, PNG, GIF, and WebP are allowed"]);
            }
            
            if ($_FILES['image']['size'] > 5 * 1024 * 1024) { // 5MB limit
                send_json(["status" => "error", "message" => "Image size must be less than 5MB"]);
            }
            
            $ext = pathinfo($_FILES['image']['name'], PATHINFO_EXTENSION);
            $imageName = uniqid("course_") . "." . strtolower($ext);
            $dest = $uploadDir . $imageName;
            
            if (!move_uploaded_file($_FILES['image']['tmp_name'], $dest)) {
                send_json(["status" => "error", "message" => "Failed to upload image"]);
            }
        }

        $stmt = $conn->prepare("INSERT INTO courses (title, description, tags, image, created_at) VALUES (?, ?, ?, ?, NOW())");
        $stmt->bind_param("ssss", $title, $desc, $tags, $imageName);
        
        if ($stmt->execute()) {
            send_json(["status" => "success", "message" => "Course added successfully"]);
        } else {
            send_json(["status" => "error", "message" => "Failed to add course: " . $conn->error]);
        }

    case 'get_courses':
        $res = $conn->query("SELECT id, title, description, tags, image, created_at FROM courses ORDER BY id DESC");
        $courses = [];
        while ($row = $res->fetch_assoc()) {
            $courses[] = $row;
        }
        send_json(["status" => "success", "courses" => $courses]);

    case 'delete_course':
        $data = get_input();
        $id = $data['id'] ?? '';
        if (!$id || !is_numeric($id)) {
            send_json(["status" => "error", "message" => "Valid course ID is required"]);
        }
        
        // Get course image to delete file
        $stmt_get = $conn->prepare("SELECT image FROM courses WHERE id = ?");
        $stmt_get->bind_param("i", $id);
        $stmt_get->execute();
        $result = $stmt_get->get_result();
        $course = $result->fetch_assoc();
        
        // Delete related records in course_progress first
        $stmt1 = $conn->prepare("DELETE FROM course_progress WHERE course_id = ?");
        $stmt1->bind_param("i", $id);
        $stmt1->execute();
        
        // Delete the course
        $stmt = $conn->prepare("DELETE FROM courses WHERE id = ?");
        $stmt->bind_param("i", $id);
        
        if ($stmt->execute()) {
            if ($stmt->affected_rows > 0) {
                // Delete image file if exists
                if ($course && $course['image']) {
                    $imagePath = __DIR__ . "/uploads/" . $course['image'];
                    if (file_exists($imagePath)) {
                        unlink($imagePath);
                    }
                }
                send_json(["status" => "success", "message" => "Course deleted successfully"]);
            } else {
                send_json(["status" => "error", "message" => "Course not found"]);
            }
        } else {
            send_json(["status" => "error", "message" => "Failed to delete course: " . $conn->error]);
        }

    // === ADMIN FUNCTIONALITY ===
    case 'admin_login':
        $data = get_input();
        $email = clean($data['email'] ?? '');
        $password = $data['password'] ?? '';
        
        if ($email === '' || $password === '') {
            send_json(["status" => "error", "message" => "Email and password are required"]);
        }
        
        $stmt = $conn->prepare("SELECT * FROM admins WHERE email=? AND password=? LIMIT 1");
        $stmt->bind_param("ss", $email, $password);
        $stmt->execute();
        $res = $stmt->get_result();
        
        if ($res->num_rows > 0) {
            $admin = $res->fetch_assoc();
            $_SESSION['admin_id'] = $admin['id'];
            send_json(["status" => "success", "admin" => $admin, "message" => "Admin login successful"]);
        } else {
            send_json(["status" => "error", "message" => "Invalid admin credentials"]);
        }

    case 'admin_stats':
        $users = $conn->query("SELECT COUNT(*) as total FROM users")->fetch_assoc()['total'] ?? 0;
        $courses = $conn->query("SELECT COUNT(*) as total FROM courses")->fetch_assoc()['total'] ?? 0;
        $completed = $conn->query("SELECT COUNT(*) as total FROM course_progress WHERE status='completed'")
                          ->fetch_assoc()['total'] ?? 0;
        $pending = $conn->query("SELECT COUNT(*) as total FROM course_progress WHERE status='pending'")
                        ->fetch_assoc()['total'] ?? 0;
        
        send_json([
            "status" => "success",
            "data" => [
                "users" => (int)$users,
                "courses" => (int)$courses,
                "completed" => (int)$completed,
                "pending" => (int)$pending
            ]
        ]);

    // === ENROLLMENT FUNCTIONALITY ===
    case 'get_available':
        $user_id = $_GET['user_id'] ?? 0;
        $user_id = intval($user_id);
        if ($user_id <= 0) {
            send_json(["status" => "error", "message" => "Valid user ID is required"]);
        }

        $sql = "SELECT * FROM courses WHERE id NOT IN (SELECT course_id FROM course_progress WHERE user_id = ?) ORDER BY id DESC";
        $stmt = $conn->prepare($sql);
        $stmt->bind_param("i", $user_id);
        $stmt->execute();
        $res = $stmt->get_result();
        $courses = [];
        while ($row = $res->fetch_assoc()) {
            $courses[] = $row;
        }
        send_json(["status" => "success", "courses" => $courses]);

    case 'get_enrolled':
        $user_id = $_GET['user_id'] ?? 0;
        $user_id = intval($user_id);
        if ($user_id <= 0) {
            send_json(["status" => "error", "message" => "Valid user ID is required"]);
        }

        $sql = "SELECT c.*, p.status, p.enrolled_at FROM courses c 
                JOIN course_progress p ON c.id = p.course_id 
                WHERE p.user_id = ? ORDER BY p.enrolled_at DESC";
        $stmt = $conn->prepare($sql);
        $stmt->bind_param("i", $user_id);
        $stmt->execute();
        $res = $stmt->get_result();
        $courses = [];
        while ($row = $res->fetch_assoc()) {
            $courses[] = $row;
        }
        send_json(["status" => "success", "courses" => $courses]);

    case 'enroll':
        $data = get_input();
        $user_id = intval($_GET['user_id'] ?? 0);
        $course_id = intval($data['course_id'] ?? 0);
        
        if ($user_id <= 0 || $course_id <= 0) {
            send_json(["status" => "error", "message" => "Valid user ID and course ID are required"]);
        }

        // Check if user exists
        $user_check = $conn->prepare("SELECT id FROM users WHERE id = ?");
        $user_check->bind_param("i", $user_id);
        $user_check->execute();
        $user_check->store_result();
        if ($user_check->num_rows === 0) {
            send_json(["status" => "error", "message" => "User not found"]);
        }

        // Check if course exists
        $course_check = $conn->prepare("SELECT id FROM courses WHERE id = ?");
        $course_check->bind_param("i", $course_id);
        $course_check->execute();
        $course_check->store_result();
        if ($course_check->num_rows === 0) {
            send_json(["status" => "error", "message" => "Course not found"]);
        }

        // Check if already enrolled
        $check = $conn->prepare("SELECT id FROM course_progress WHERE user_id = ? AND course_id = ?");
        $check->bind_param("ii", $user_id, $course_id);
        $check->execute();
        $check->store_result();
        if ($check->num_rows > 0) {
            send_json(["status" => "error", "message" => "Already enrolled in this course"]);
        }

        // Enroll user
        $stmt = $conn->prepare("INSERT INTO course_progress (user_id, course_id, status, enrolled_at) VALUES (?, ?, 'pending', NOW())");
        $stmt->bind_param("ii", $user_id, $course_id);
        
        if ($stmt->execute()) {
            send_json(["status" => "success", "message" => "Successfully enrolled in course"]);
        } else {
            send_json(["status" => "error", "message" => "Enrollment failed: " . $conn->error]);
        }

    // === IMAGE UPLOAD (Legacy support) ===
    case 'upload_image':
        if (!isset($_FILES["image"])) {
            send_json(["status" => "error", "message" => "No image file provided"]);
        }
        
        $targetDir = __DIR__ . "/uploads/";
        if (!is_dir($targetDir)) {
            if (!mkdir($targetDir, 0777, true)) {
                send_json(["status" => "error", "message" => "Failed to create upload directory"]);
            }
        }
        
        $allowedTypes = ['image/jpeg', 'image/png', 'image/gif', 'image/webp'];
        $fileType = $_FILES['image']['type'];
        if (!in_array($fileType, $allowedTypes)) {
            send_json(["status" => "error", "message" => "Invalid image type"]);
        }
        
        if ($_FILES['image']['size'] > 5 * 1024 * 1024) { // 5MB limit
            send_json(["status" => "error", "message" => "Image size too large"]);
        }
        
        $fileName = time() . "_" . basename($_FILES["image"]["name"]);
        $targetFilePath = $targetDir . $fileName;
        
        if (move_uploaded_file($_FILES["image"]["tmp_name"], $targetFilePath)) {
            send_json(["status" => "success", "image_url" => "uploads/" . $fileName]);
        } else {
            send_json(["status" => "error", "message" => "Image upload failed"]);
        }

    // === DEFAULT CASE ===
    default:
        send_json(["status" => "error", "message" => "Invalid or missing action parameter"]);
}

$conn->close();
?>