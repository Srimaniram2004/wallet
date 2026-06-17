import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileManagementScreen extends StatefulWidget {
  const ProfileManagementScreen({
    super.key,
  });

  @override
  State<ProfileManagementScreen> createState() =>
      _ProfileManagementScreenState();
}

class _ProfileManagementScreenState
    extends State<ProfileManagementScreen> {
  List<String> defaultProfiles = [
    'Personal',
    'Business',
    'New Home',
  ];

  List<String> projects = [];

  String selectedProfile = 'Personal';

  @override
  void initState() {
    super.initState();
    loadData();
  }

  //////////////////////////////////////////////////
  // LOAD DATA
  //////////////////////////////////////////////////

  Future<void> loadData() async {
    final prefs =
        await SharedPreferences.getInstance();

    projects =
        prefs.getStringList('projects') ?? [];

    selectedProfile =
        prefs.getString('selectedProfile') ??
            'Personal';

    setState(() {});
  }

  //////////////////////////////////////////////////
  // SELECT PROFILE
  //////////////////////////////////////////////////

  Future<void> selectProfile(
    String profile,
  ) async {
    final prefs =
        await SharedPreferences.getInstance();

    await prefs.setString(
      'selectedProfile',
      profile,
    );

    setState(() {
      selectedProfile = profile;
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(
          '$profile selected',
        ),
      ),
    );
  }

  //////////////////////////////////////////////////
  // CREATE PROJECT
  //////////////////////////////////////////////////

  Future<void> createProject() async {
    final controller =
        TextEditingController();

    await showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title:
              const Text("Create Project"),
          content: TextField(
            controller: controller,
            decoration:
                const InputDecoration(
              hintText: "Project Name",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                String project =
                    controller.text.trim();

                if (project.isEmpty) {
                  return;
                }

                final prefs =
                    await SharedPreferences
                        .getInstance();

                projects.add(project);

                await prefs.setStringList(
                  'projects',
                  projects,
                );

                if (!mounted) return;

                Navigator.pop(context);

                setState(() {});
              },
              child:
                  const Text("Create"),
            ),
          ],
        );
      },
    );
  }

  //////////////////////////////////////////////////
  // DELETE PROJECT
  //////////////////////////////////////////////////

  Future<void> deleteProject(
    String project,
  ) async {
    final confirm =
        await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title:
              const Text("Delete Project"),
          content: Text(
            'Delete "$project" ?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                    context, false);
              },
              child: const Text("No"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                    context, true);
              },
              child: const Text("Yes"),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    final prefs =
        await SharedPreferences.getInstance();

    projects.remove(project);

    await prefs.setStringList(
      'projects',
      projects,
    );

    //////////////////////////////////////////////////
    // IF DELETED PROFILE IS SELECTED
    //////////////////////////////////////////////////

    if (selectedProfile == project) {
      selectedProfile = 'Personal';

      await prefs.setString(
        'selectedProfile',
        'Personal',
      );
    }

    setState(() {});
  }

  //////////////////////////////////////////////////
  // PROFILE TILE
  //////////////////////////////////////////////////

  Widget buildProfileTile(
    String profile,
    IconData icon,
  ) {
    final isSelected =
        selectedProfile == profile;

    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(profile),
        trailing: isSelected
            ? const Icon(
                Icons.check_circle,
                color: Colors.green,
              )
            : null,
        onTap: () =>
            selectProfile(profile),
      ),
    );
  }

  //////////////////////////////////////////////////
  // BUILD
  //////////////////////////////////////////////////

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text("Manage Profiles"),
      ),

      floatingActionButton:
          FloatingActionButton.extended(
        onPressed: createProject,
        icon: const Icon(Icons.add),
        label:
            const Text("Create Project"),
      ),

      body: ListView(
        padding:
            const EdgeInsets.all(16),
        children: [
          //////////////////////////////////////////////////
          // DEFAULT PROFILES
          //////////////////////////////////////////////////

          const Text(
            "Profiles",
            style: TextStyle(
              fontSize: 18,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          buildProfileTile(
            'Personal',
            Icons.person,
          ),

          buildProfileTile(
            'Business',
            Icons.business,
          ),

          buildProfileTile(
            'New Home',
            Icons.home,
          ),

          const SizedBox(height: 25),

          //////////////////////////////////////////////////
          // PROJECTS
          //////////////////////////////////////////////////

          const Text(
            "Projects",
            style: TextStyle(
              fontSize: 18,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          if (projects.isEmpty)
            const Card(
              child: Padding(
                padding:
                    EdgeInsets.all(20),
                child: Center(
                  child: Text(
                    "No Projects Created",
                  ),
                ),
              ),
            ),

          ...projects.map(
            (project) {
              final isSelected =
                  selectedProfile ==
                      project;

              return Card(
                child: ListTile(
                  leading: const Icon(
                    Icons.folder,
                    color:
                        Colors.orange,
                  ),
                  title: Text(project),
                  trailing: Row(
                    mainAxisSize:
                        MainAxisSize.min,
                    children: [
                      if (isSelected)
                        const Icon(
                          Icons.check_circle,
                          color:
                              Colors.green,
                        ),

                      IconButton(
                        icon: const Icon(
                          Icons.delete,
                          color:
                              Colors.red,
                        ),
                        onPressed: () {
                          deleteProject(
                            project,
                          );
                        },
                      ),
                    ],
                  ),
                  onTap: () =>
                      selectProfile(
                    project,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}