import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';

class GroupService {
  GroupService._();
  static final SupabaseClient _client = Supabase.instance.client;

  /// Groups the current user has joined.
  static Future<List<AppGroup>> fetchMyGroups() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];
    final rows = await _client
        .from('group_members')
        .select('groups(*)')
        .eq('user_id', userId);

    final groups = <AppGroup>[];
    for (final row in rows) {
      final g = row['groups'];
      if (g is Map<String, dynamic>) {
        final count = await _memberCount(g['id'] as String);
        groups.add(AppGroup.fromMap(g, memberCount: count));
      }
    }
    return groups;
  }

  /// Groups the current user has NOT joined yet, for the Discover tab.
  static Future<List<AppGroup>> fetchDiscoverGroups() async {
    final userId = _client.auth.currentUser?.id;
    final myGroupIds = userId == null
        ? <String>[]
        : (await _client.from('group_members').select('group_id').eq('user_id', userId))
            .map<String>((r) => r['group_id'] as String)
            .toList();

    final rows = await _client.from('groups').select();
    final groups = <AppGroup>[];
    for (final row in rows) {
      if (myGroupIds.contains(row['id'])) continue;
      final count = await _memberCount(row['id'] as String);
      groups.add(AppGroup.fromMap(row, memberCount: count));
    }
    return groups;
  }

  static Future<int> _memberCount(String groupId) async {
    final rows = await _client.from('group_members').select('user_id').eq('group_id', groupId);
    return rows.length;
  }

  static Future<void> joinGroup(String groupId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('Must be signed in to join a group.');
    await _client.from('group_members').insert({'group_id': groupId, 'user_id': userId});
  }

  static Future<void> leaveGroup(String groupId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;
    await _client.from('group_members').delete().eq('group_id', groupId).eq('user_id', userId);
  }

  static Future<List<GroupMessage>> fetchMessages(String groupId) async {
    final rows = await _client
        .from('group_messages')
        .select('*, profiles(username)')
        .eq('group_id', groupId)
        .order('created_at', ascending: false);
    return rows.map<GroupMessage>((r) => GroupMessage.fromMap(r)).toList();
  }

  static Future<void> postMessage({required String groupId, required String content}) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('Must be signed in to post in a group.');
    await _client.from('group_messages').insert({
      'group_id': groupId,
      'author_id': userId,
      'content': content,
    });
  }
}
