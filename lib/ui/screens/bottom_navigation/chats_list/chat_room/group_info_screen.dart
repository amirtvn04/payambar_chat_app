import 'package:payambar/core/constants/colors.dart';
import 'package:payambar/core/constants/styles.dart';
import 'package:payambar/core/models/group_model.dart';
import 'package:payambar/core/models/user_model.dart';
import 'package:payambar/core/services/database_service.dart';
import 'package:payambar/ui/screens/other/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class GroupInfoScreen extends StatefulWidget {
  final GroupModel group;

  const GroupInfoScreen({super.key, required this.group});

  @override
  State<GroupInfoScreen> createState() => _GroupInfoScreenState();
}

class _GroupInfoScreenState extends State<GroupInfoScreen> {
  final DatabaseService _db = DatabaseService();
  List<UserModel> _members = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    try {
      final users = await _db.fetchUsersByIds(widget.group.members ?? []);
      setState(() {
        _members = users;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  Future<void> _removeMember(String userId) async {
    try {
      await _db.removeMemberFromGroup(widget.group.groupId!, userId);

      setState(() {
        _members.removeWhere((user) => user.uid == userId);
        widget.group.members?.remove(userId);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Member removed successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<UserProvider>(context).user;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Group Info"),
        backgroundColor: primary,
        foregroundColor: white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // اطلاعات گروه
            Center(
              child: CircleAvatar(
                radius: 50.r,
                backgroundColor: Colors.blue.withOpacity(0.2),
                child: const Icon(
                  Icons.group,
                  color: Colors.blue,
                  size: 50,
                ),
              ),
            ),
            20.verticalSpace,
            Center(
              child: Text(
                widget.group.name ?? "No Name",
                style: h.copyWith(fontSize: 24.sp),
              ),
            ),
            10.verticalSpace,
            Center(
              child: Text(
                widget.group.description ?? "No description",
                style: body.copyWith(color: grey),
                textAlign: TextAlign.center,
              ),
            ),
            20.verticalSpace,
            Divider(color: grey.withOpacity(0.3)),

            // لیست اعضا
            Text("Members (${_members.length})", style: h.copyWith(fontSize: 18.sp)),
            10.verticalSpace,
            Expanded(
              child: ListView.builder(
                itemCount: _members.length,
                itemBuilder: (context, index) {
                  final member = _members[index];
                  final isCurrentUser = member.uid == currentUser?.uid;

                  return Container(
                    margin: EdgeInsets.only(bottom: 10.h),
                    child: ListTile(
                      tileColor: grey.withOpacity(0.12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      leading: member.imageUrl == null
                          ? CircleAvatar(
                        backgroundColor: grey.withOpacity(0.5),
                        radius: 25,
                        child: Text(member.name![0], style: h),
                      )
                          : CircleAvatar(
                        backgroundImage: NetworkImage(member.imageUrl!),
                      ),
                      title: Text(member.name ?? "Unknown"),
                      subtitle: Text(member.email ?? ""),
                      trailing: !isCurrentUser
                          ? IconButton(
                        icon: const Icon(Icons.group_remove, color: Colors.red),
                        onPressed: () => _showRemoveDialog(member),
                      )
                          : null,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRemoveDialog(UserModel member) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Remove Member"),
        content: Text("Are you sure you want to remove ${member.name} from the group?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _removeMember(member.uid!);
            },
            child: const Text("Remove", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}