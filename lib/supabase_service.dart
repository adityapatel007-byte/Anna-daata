import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final supabase = Supabase.instance.client;
  
  // Current user storage
  static String? currentUserEmail;
  static String? currentUserId;
  static String? currentUserRole;
  
  // Store user account
  static Future<bool> storeAccount(String email, String name, String phone, String password, String role) async {
    try {
      final response = await supabase
          .from('users')
          .insert({
            'email': email,
            'name': name,
            'phone': phone,
            'password': password, // In production, hash this!
            'role': role,
          })
          .select()
          .single();
      
      // Set current user
      currentUserEmail = email;
      currentUserId = response['id'];
      currentUserRole = role;
      
      return true;
    } catch (e) {
      print('Error storing account: $e');
      return false;
    }
  }
  
  // Check if account exists
  static Future<bool> accountExists(String email) async {
    try {
      final response = await supabase
          .from('users')
          .select('id')
          .eq('email', email)
          .maybeSingle();
      
      return response != null;
    } catch (e) {
      return false;
    }
  }
  
  // Validate user credentials
  static Future<bool> validatePassword(String email, String password) async {
    try {
      final response = await supabase
          .from('users')
          .select('id, role')
          .eq('email', email)
          .eq('password', password) // In production, hash and compare!
          .maybeSingle();
      
      if (response != null) {
        currentUserEmail = email;
        currentUserId = response['id'];
        currentUserRole = response['role'];
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
  
  // Get user data
  static Future<Map<String, dynamic>?> getUserData(String email) async {
    try {
      final response = await supabase
          .from('users')
          .select('*')
          .eq('email', email)
          .maybeSingle();
      
      return response;
    } catch (e) {
      return null;
    }
  }
  
  // Add food post
  static Future<bool> addFoodPost(String description, String location, String pickupTime) async {
    try {
      if (currentUserId == null) return false;
      
      await supabase
          .from('food_posts')
          .insert({
            'volunteer_id': currentUserId,
            'description': description,
            'location': location,
            'pickup_time': pickupTime,
          });
      
      return true;
    } catch (e) {
      print('Error adding food post: $e');
      return false;
    }
  }
  
  // Get available food posts
  static Future<List<Map<String, dynamic>>> getAvailableFoodPosts() async {
    try {
      final sixHoursAgo = DateTime.now().subtract(Duration(hours: 6)).toIso8601String();
      
      final response = await supabase
          .from('food_posts')
          .select('''
            *,
            users!volunteer_id (
              name,
              phone
            )
          ''')
          .eq('is_claimed', false)
          .gte('created_at', sixHoursAgo)
          .order('created_at', ascending: false);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error getting food posts: $e');
      return [];
    }
  }
  
  // Claim food post
  static Future<bool> claimFoodPost(String postId) async {
    try {
      if (currentUserId == null) return false;
      
      await supabase
          .from('food_posts')
          .update({
            'is_claimed': true,
            'claimed_by': currentUserId,
          })
          .eq('id', postId);
      
      return true;
    } catch (e) {
      print('Error claiming food post: $e');
      return false;
    }
  }
  
  // Set current user (for login)
  static void setCurrentUser(String email, String userId, String role) {
    currentUserEmail = email;
    currentUserId = userId;
    currentUserRole = role;
  }
  
  // Clear current user (for logout)
  static void clearCurrentUser() {
    currentUserEmail = null;
    currentUserId = null;
    currentUserRole = null;
  }
}