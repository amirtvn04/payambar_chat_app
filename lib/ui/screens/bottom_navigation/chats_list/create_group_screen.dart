import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chat_app/core/models/user_model.dart';
import 'package:chat_app/core/models/group_model.dart'; // اضافه کردن import مدل گروه
import 'package:chat_app/core/services/database_service.dart';
import 'package:chat_app/ui/screens/other/user_provider.dart';

import '../../../widgets/textfield_widget.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final TextEditingController _groupNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController(); // اضافه کردن کنترلر برای توضیحات
  final List<UserModel> _selectedUsers = [];
  bool _loading = false;
  List<UserModel> _allUsers = [];

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    setState(() => _loading = true);
    final db = DatabaseService();
    final currentUser =
    Provider.of<UserProvider>(context, listen: false).user!;
    final usersMap = await db.fetchUsers(currentUser.uid!);
    setState(() {
      _allUsers = usersMap!.map((e) => UserModel.fromMap(e)).toList();
      _loading = false;
    });
  }

  void _toggleUserSelection(UserModel user) {
    setState(() {
      if (_selectedUsers.contains(user)) {
        _selectedUsers.remove(user);
      } else {
        _selectedUsers.add(user);
      }
    });
  }

  Future<void> _createGroup() async {
    if (_groupNameController.text.isEmpty || _selectedUsers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter name and member")),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final currentUser =
      Provider.of<UserProvider>(context, listen: false).user!;

      final groupData = {
        "groupId": DateTime.now().millisecondsSinceEpoch.toString(),
        "name": _groupNameController.text.trim(),
        "description": _descriptionController.text.trim(),
        "members": [currentUser.uid, ..._selectedUsers.map((u) => u.uid)],
        "createdAt": DateTime.now().millisecondsSinceEpoch,
        "createdBy": currentUser.uid,
        "lastMessage": null,
        "unreadCounter": 0,
      };

      await DatabaseService().createGroup(groupData);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Group created successfully!")),
        );
      }
    } catch (e) {
      debugPrint("Error creating group: $e");
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Group")),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CustomTextfield(
              controller: _groupNameController,
              hintText: "Group Name",
              onChanged: (value) {
              },
              isPassword: false,
              isChatText: false,
              isSearch: false,
            ),
            const SizedBox(height: 16),
            CustomTextfield(
              controller: _descriptionController,
              hintText: "Group Description (Optional)",
              onChanged: (value) {
              },
              isPassword: false,
              isChatText: false,
              isSearch: false,
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            const Text(
              "Select Members:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: _allUsers.length,
                itemBuilder: (context, index) {
                  final user = _allUsers[index];
                  final isSelected = _selectedUsers.contains(user);
                  return ListTile(
                    leading: user.imageUrl == null
                        ? CircleAvatar(child: Text(user.name![0]))
                        : CircleAvatar(
                      backgroundImage: NetworkImage(user.imageUrl!),
                    ),
                    title: Text(user.name ?? ""),
                    trailing: Checkbox(
                      value: isSelected,
                      onChanged: (val) => _toggleUserSelection(user),
                    ),
                    onTap: () => _toggleUserSelection(user),
                  );
                },
              ),
            ),
            ElevatedButton.icon(
              onPressed: _createGroup,
              icon: const Icon(Icons.check),
              label: const Text("Create Group"),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
            )
          ],
        ),
      ),
    );
  }
}