import 'package:flutter/material.dart';
import 'package:mental_health_flutter/models/community.dart';

class CommunityList extends StatelessWidget {
  final Future<List<Community>> communitiesFuture;
  final Function(Community) onCommunitySelected;
  final Community? selectedCommunity;
  final String backendUrl;

  const CommunityList({
    super.key,
    required this.communitiesFuture,
    required this.onCommunitySelected,
    required this.selectedCommunity,
    required this.backendUrl,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 768;
    return Container(
      width: isTablet ? screenWidth * 0.25 : 80,
      color: Colors.grey[100],
      child: FutureBuilder<List<Community>>(
        future: communitiesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Failed to load communities: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final communities = snapshot.data!;
            return ListView.builder(
              itemCount: communities.length,
              itemBuilder: (context, index) {
                final community = communities[index];
                return InkWell(
                  onTap: () => onCommunitySelected(community),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
                    decoration: BoxDecoration(
                      color: selectedCommunity?.id == community.id
                          ? Colors.blue.withOpacity(0.2)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 25,
                          backgroundColor: Colors.grey[300],
                          foregroundImage: community.profilePhoto.isNotEmpty
                              ? NetworkImage('$backendUrl/storage/${community.profilePhoto}') as ImageProvider<Object>?
                              : null,
                          onForegroundImageError: (exception, stackTrace) {
                            debugPrint('Error loading community avatar: $exception');
                          },
                          child: community.profilePhoto.isEmpty ? const Icon(Icons.group, size: 50) : null,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          community.name,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          } else {
            return const Center(child: Text('No communities found.'));
          }
        },
      ),
    );
  }
}