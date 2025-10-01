class UserStorage {
  // Simple storage for credentials
  static Map<String, Map<String, String>> storedAccounts = {};
  
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
}
