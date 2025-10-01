// Supabase Integration Setup
// 
// To implement Supabase database:
// 
// 1. Add dependencies to pubspec.yaml:
//    dependencies:
//      supabase_flutter: ^1.10.25
//
// 2. Initialize Supabase in main.dart:
//    import 'package:supabase_flutter/supabase_flutter.dart';
//    
//    Future<void> main() async {
//      WidgetsFlutterBinding.ensureInitialized();
//      
//      await Supabase.initialize(
//        url: 'YOUR_SUPABASE_URL',
//        anonKey: 'YOUR_SUPABASE_ANON_KEY',
//      );
//      
//      runApp(const MyApp());
//    }
//
// 3. Create tables in Supabase:
//    
//    Table: users
//    - id (uuid, primary key)
//    - email (text, unique)
//    - name (text)
//    - phone (text)
//    - password (text)
//    - role (text) -- 'volunteer' or 'ngo'
//    - created_at (timestamp)
//    
//    Table: food_posts
//    - id (uuid, primary key)
//    - volunteer_id (uuid, foreign key to users.id)
//    - description (text)
//    - location (text)
//    - pickup_time (text)
//    - created_at (timestamp)
//    - is_claimed (boolean, default false)
//    - claimed_by (uuid, foreign key to users.id, nullable)
//
// 4. Replace UserStorage with SupabaseService:

import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final supabase = Supabase.instance.client;
  
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
          });
      return true;
    } catch (e) {
      return false;
    }
  }
  
  // Validate user credentials
  static Future<Map<String, dynamic>?> validateUser(String email, String password) async {
    try {
      final response = await supabase
          .from('users')
          .select()
          .eq('email', email)
          .eq('password', password) // In production, hash and compare!
          .maybeSingle();
      
      return response;
    } catch (e) {
      return null;
    }
  }
  
  // Add food post
  static Future<bool> addFoodPost(String volunteerEmail, String description, String location, String pickupTime) async {
    try {
      // Get volunteer ID
      final volunteer = await supabase
          .from('users')
          .select('id')
          .eq('email', volunteerEmail)
          .maybeSingle();
      
      if (volunteer == null) return false;
      
      await supabase
          .from('food_posts')
          .insert({
            'volunteer_id': volunteer['id'],
            'description': description,
            'location': location,
            'pickup_time': pickupTime,
          });
      
      return true;
    } catch (e) {
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
      return [];
    }
  }
  
  // Claim food post
  static Future<bool> claimFoodPost(String postId, String ngoUserId) async {
    try {
      await supabase
          .from('food_posts')
          .update({
            'is_claimed': true,
            'claimed_by': ngoUserId,
          })
          .eq('id', postId);
      
      return true;
    } catch (e) {
      return false;
    }
  }
}

// Note: To use this, replace all UserStorage calls with SupabaseService calls
// and handle the async nature of database operations with FutureBuilder or async/await