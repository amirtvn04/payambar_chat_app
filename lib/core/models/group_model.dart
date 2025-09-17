import 'dart:convert';
import 'dart:developer';

class GroupModel {
  final String? groupId;
  final String? name;
  final String? description;
  final String? createdBy;
  final DateTime? createdAt;
  final List<String>? members;
  final Map<String, dynamic>? lastMessage;
  final int? unreadCounter;

  GroupModel({
    this.groupId,
    this.name,
    this.description,
    this.createdBy,
    this.createdAt,
    this.members,
    this.lastMessage,
    this.unreadCounter,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'groupId': groupId,
      'name': name,
      'description': description,
      'createdBy': createdBy,
      'createdAt': createdAt?.millisecondsSinceEpoch,
      'members': members,
      'lastMessage': lastMessage,
      'unreadCounter': unreadCounter,
    };
  }

  factory GroupModel.fromMap(Map<String, dynamic> map) {
    log(map.toString());
    return GroupModel(
      groupId: map['groupId'] != null ? map['groupId'] as String : null,
      name: map['name'] != null ? map['name'] as String : null,
      description: map['description'] != null ? map['description'] as String : null,
      createdBy: map['createdBy'] != null ? map['createdBy'] as String : null,
      createdAt: map['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int)
          : null,
      members: map['members'] != null
          ? List<String>.from(map['members'] as List)
          : null,
      lastMessage: map['lastMessage'] != null
          ? Map<String, dynamic>.from(map['lastMessage'] as Map<String, dynamic>)
          : null,
      unreadCounter: map['unreadCounter'] != null ? map['unreadCounter'] as int : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory GroupModel.fromJson(String source) =>
      GroupModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'GroupModel(groupId: $groupId, name: $name, description: $description, '
        'createdBy: $createdBy, createdAt: $createdAt, '
        'members: $members, lastMessage: $lastMessage, '
        'unreadCounter: $unreadCounter)';
  }

  bool isMember(String userId) {
    return members?.contains(userId) ?? false;
  }

  int get membersCount => members?.length ?? 0;
}