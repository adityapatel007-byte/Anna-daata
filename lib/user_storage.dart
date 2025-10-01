class UserStorage {
  // Simple storage for credentials
  static Map<String, Map<String, String>> storedAccounts = {};
  
  // Storage for food posts
  static List<Map<String, dynamic>> foodPosts = [];
  
  // Store user account
  static void storeAccount(String email, String name, String phone, String password) {
    storedAccounts[email] = {
      'name': name,
      'phone': phone,
      'password': password,
    };
  }
  
  // Check if account exists
  static bool accountExists(String email) {
    return storedAccounts.containsKey(email);
  }
  
  // Validate password
  static bool validatePassword(String email, String password) {
    if (!accountExists(email)) return false;
    return storedAccounts[email]!['password'] == password;
  }
  
  // Get user data
  static Map<String, String>? getUserData(String email) {
    return storedAccounts[email];
  }
  
  // Add food post
  static void addFoodPost(String volunteerEmail, String description, String location, String time) {
    final volunteerData = getUserData(volunteerEmail);
    if (volunteerData != null) {
      foodPosts.add({
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'volunteerEmail': volunteerEmail,
        'volunteerName': volunteerData['name']!,
        'description': description,
        'location': location,
        'time': time,
        'timestamp': DateTime.now().toIso8601String(),
      });
    }
  }
  
  // Get available food posts (removing expired ones)
  static Future<List<Map<String, dynamic>>> getAvailableFoodPosts() async {
    final now = DateTime.now();
    
    // Remove posts older than 6 hours
    foodPosts.removeWhere((post) {
      final postTime = DateTime.parse(post['timestamp']);
      return now.difference(postTime).inHours >= 6;
    });
    
    return List.from(foodPosts);
  }
  
  // Get current volunteer email (you'll need to track this)
  static String? currentVolunteerEmail;
  
  static void setCurrentVolunteer(String email) {
    currentVolunteerEmail = email;
  }
}
