import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'main.dart';
import 'quote_screen.dart';
import 'app_localization.dart';

class ProfileSelectionScreen extends StatefulWidget {
  final bool isDark;
  final VoidCallback toggleTheme;
    final ValueChanged<Locale> onLocaleChange;

  const ProfileSelectionScreen({
    super.key,
    required this.isDark,
    required this.toggleTheme,
    required this.onLocaleChange,
  });

  @override
  State<ProfileSelectionScreen> createState() =>
      _ProfileSelectionScreenState();
}

class _ProfileSelectionScreenState
    extends State<ProfileSelectionScreen> {
  List<String> projects = [];

  @override
  void initState() {
    super.initState();
    loadProjects();
  }

  Future<void> loadProjects() async {
    final prefs = await SharedPreferences.getInstance();

    projects = prefs.getStringList('projects') ?? [];

    if (mounted) {
      setState(() {});
    }
  }
Future<void> selectProfile(String profile) async {
  final prefs = await SharedPreferences.getInstance();

  await prefs.setString(
    'selectedProfile',
    profile,
  );

  if (!mounted) return;

  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (_) => MainScreen(
        isDark: widget.isDark,
        toggleTheme: widget.toggleTheme,
        onLocaleChange: widget.onLocaleChange,

      ),
    ),
  );
}
  Future<void> createProject() async {
    final controller = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
                AppLocalizations.of(context)
                    .tr('create_project'),
              ),
          content: TextField(
            controller: controller,
            decoration:  InputDecoration(
              hintText: AppLocalizations.of(context).tr('enter_project_name'),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
              AppLocalizations.of(context)
                  .tr('cancel'),
            ),
            ),
            ElevatedButton(
              onPressed: () async {
                final name =
                    controller.text.trim();

                if (name.isEmpty) {
                  return;
                }

                if (projects.contains(name)) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(
                     SnackBar(
                      content: Text(
                     AppLocalizations.of(context).tr('project_already_exists')
                      ),
                    ),
                  );
                  return;
                }

                projects.add(name);

                final prefs =
                    await SharedPreferences
                        .getInstance();

                await prefs.setStringList(
                  'projects',
                  projects,
                );

                if (!mounted) return;

                Navigator.pop(context);

                setState(() {});
              },
              child: Text(
              AppLocalizations.of(context)
                  .tr('create'),
            ),
            ),
          ],
        );
      },
    );
  }

  Widget bigProfileCard({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(
        bottom: 16,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius:
            BorderRadius.circular(20),
        child: Container(
          height: 90,
          decoration: BoxDecoration(
            borderRadius:
                BorderRadius.circular(20),
            color: Colors.teal.shade50,
            border: Border.all(
              color: Colors.teal,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              const SizedBox(width: 20),
              Icon(
                icon,
                size: 35,
                color: Colors.teal,
              ),
              const SizedBox(width: 20),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildProjectTile(
    String project,
  ) {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: const Icon(
          Icons.folder,
          color: Colors.orange,
        ),
        title: Text(project),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
        ),
        onTap: () {
          selectProfile(project);
        },
      ),
    );
  }
  Widget _modernProfileCard({
  required String title,
  required String subtitle,
  required IconData icon,
  required Color color,
  required VoidCallback onTap,
}) {
  return InkWell(
    borderRadius: BorderRadius.circular(20),
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor:
                color.withOpacity(0.15),
            child: Icon(
              icon,
              color: color,
              size: 28,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            color: color,
            size: 18,
          ),
        ],
      ),
    ),
  );
}

@override
Widget build(BuildContext context) {
  final tr = AppLocalizations.of(context);
  final isDark =
      Theme.of(context).brightness == Brightness.dark;

  return Scaffold(
    backgroundColor: isDark
        ? const Color(0xFF121212)
        : const Color(0xFFF5F6FA),

    appBar: AppBar(
      elevation: 0,
      centerTitle: true,
      title:  Text(
        tr.tr('choose_profile'),
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
    ),

    body: Column(
      children: [

        //////////////////////////////////////////////////
        // HEADER
        //////////////////////////////////////////////////

        Container(
          width: double.infinity,
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),

          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF0F2027),
                Color(0xFF203A43),
                Color(0xFF2C5364),
              ],
            ),
            borderRadius:
                BorderRadius.circular(25),
          ),

          child:  Column(
            children: [
             Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Image.asset(
                      'assets/favicon.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),

              SizedBox(height: 12),

             Text(
                tr.tr('app_name'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: 6),

              Text(
                tr.tr("choose_workspace"),
                style: TextStyle(
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
            ),
            child: ListView(
              children: [

                //////////////////////////////////////////////////
                // PERSONAL
                //////////////////////////////////////////////////

                _modernProfileCard(
                  title: tr.tr("personal"),
                  subtitle:
                      tr.tr("manage_personal_expenses"),
                  icon: Icons.person,
                  color: Colors.teal,
                  onTap: () =>
                      selectProfile("Personal"),
                ),

                const SizedBox(height: 12),

                //////////////////////////////////////////////////
                // BUSINESS
                //////////////////////////////////////////////////

                _modernProfileCard(
                  title: tr.tr("business"),
                  subtitle:
                      tr.tr("track_business_finances"),
                  icon: Icons.business,
                  color: Colors.blue,
                  onTap: () =>
                      selectProfile("Business"),
                ),

                const SizedBox(height: 25),

                 Text(
                  tr.tr("projects"),
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                //////////////////////////////////////////////////
                // PROJECTS
                //////////////////////////////////////////////////

                if (projects.isEmpty)
                  Container(
                    padding:
                        const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(
                              0xFF1E1E1E)
                          : Colors.white,
                      borderRadius:
                          BorderRadius.circular(
                              18),
                    ),
                    child:  Center(
                      child: Text(
                        tr.tr("no_projects_created"),
                      ),
                    ),
                  ),

                ...projects.map(
                  (project) => Card(
                    elevation: 2,
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                              16),
                    ),
                    child: ListTile(
                      contentPadding:
                          const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 8,
                      ),
                      leading: CircleAvatar(
                        backgroundColor:
                            Colors.orange
                                .withOpacity(0.15),
                        child: const Icon(
                          Icons.folder,
                          color: Colors.orange,
                        ),
                      ),
                      title: Text(
                        project,
                        style: const TextStyle(
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                      ),
                      onTap: () =>
                          selectProfile(project),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                //////////////////////////////////////////////////
                // CREATE PROJECT
                //////////////////////////////////////////////////

                SizedBox(
                  height: 60,
                  child: ElevatedButton.icon(
                    icon:  Icon(
                      Icons.add,
                    ),
                    label:  Text(
                      tr.tr("create_project"),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                    style:
                        ElevatedButton.styleFrom(
                      backgroundColor:
                          Colors.teal,
                      foregroundColor:
                          Colors.white,
                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(
                                18),
                      ),
                    ),
                    onPressed:
                        createProject,
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
}
