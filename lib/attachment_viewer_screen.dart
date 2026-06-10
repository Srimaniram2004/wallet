import 'dart:io';
import 'package:flutter/material.dart';

class AttachmentViewerScreen extends StatelessWidget {
  final String filePath;

  const AttachmentViewerScreen({
    super.key,
    required this.filePath,
  });

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    bool isImage =
        filePath.toLowerCase().endsWith(".jpg") ||
        filePath.toLowerCase().endsWith(".jpeg") ||
        filePath.toLowerCase().endsWith(".png");

    final fileName = filePath.split('/').last;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF121212) : Colors.grey.shade100,

      appBar: AppBar(
        title: const Text("Attachment"),
        centerTitle: true,
        elevation: 0,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Center(
          child: Container(
            width: double.infinity,

            decoration: BoxDecoration(
              color:
                  isDark
                      ? const Color(0xFF1E1E1E)
                      : Colors.white,

              borderRadius:
                  BorderRadius.circular(20),

              boxShadow: [
                BoxShadow(
                  color:
                      Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),

            child: Padding(
              padding: const EdgeInsets.all(16),

              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [

                  Icon(
                    isImage
                        ? Icons.image
                        : Icons.insert_drive_file,
                    size: 50,
                    color: Colors.teal,
                  ),

                  const SizedBox(height: 10),

                  Text(
                    fileName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: 20),

                  if (isImage)
                    Expanded(
                      child: ClipRRect(
                        borderRadius:
                            BorderRadius.circular(15),

                        child: InteractiveViewer(
                          minScale: 0.5,
                          maxScale: 5,

                          child: Image.file(
                            File(filePath),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    )
                  else
                    Container(
                      padding:
                          const EdgeInsets.all(20),

                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.black26
                            : Colors.grey.shade100,

                        borderRadius:
                            BorderRadius.circular(12),
                      ),

                      child: Column(
                        children: [
                          const Icon(
                            Icons.description,
                            size: 60,
                            color: Colors.orange,
                          ),

                          const SizedBox(height: 10),

                          const Text(
                            "File Attached",
                            style: TextStyle(
                              fontWeight:
                                  FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),

                          const SizedBox(height: 8),

                          Text(
                            fileName,
                            textAlign:
                                TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}