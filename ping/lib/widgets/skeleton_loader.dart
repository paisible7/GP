import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class SessionHistorySkeleton extends StatelessWidget {
  const SessionHistorySkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: 3, // Display 3 placeholder groups
        itemBuilder: (context, index) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Placeholder for course title
              Container(
                margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                width: 200,
                height: 24.0,
                color: Colors.white,
              ),
              // Placeholders for sessions
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 2, // Display 2 placeholder sessions per group
                itemBuilder: (context, sessionIndex) {
                  return ListTile(
                    title: Container(
                      width: double.infinity,
                      height: 18.0,
                      color: Colors.white,
                    ),
                    subtitle: Container(
                      margin: const EdgeInsets.only(top: 4.0),
                      width: 100,
                      height: 14.0,
                      color: Colors.white,
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  );
                },
                separatorBuilder: (context, index) =>
                    const Divider(height: 1, indent: 16, endIndent: 16),
              ),
            ],
          );
        },
      ),
    );
  }
}

class AttendanceHistorySkeleton extends StatelessWidget {
  const AttendanceHistorySkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: 5,
        itemBuilder: (context, index) {
          return Column(
            children: [
              ListTile(
                leading: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                title: Container(
                  width: double.infinity,
                  height: 18.0,
                  color: Colors.white,
                ),
                subtitle: Container(
                  margin: const EdgeInsets.only(top: 4.0),
                  width: 100,
                  height: 14.0,
                  color: Colors.white,
                ),
                trailing: Container(
                  width: 48,
                  height: 16,
                  color: Colors.white,
                ),
              ),
              const Divider(height: 1, indent: 16, endIndent: 16),
            ],
          );
        },
      ),
    );
  }
}

class SessionDetailsSkeleton extends StatelessWidget {
  const SessionDetailsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 180,
                  height: 24.0,
                  color: Colors.white,
                ),
                const SizedBox(height: 8),
                Container(
                  width: 120,
                  height: 18.0,
                  color: Colors.white,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              itemCount: 8,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                  title: Container(
                    width: double.infinity,
                    height: 18.0,
                    color: Colors.white,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class SimpleListSkeleton extends StatelessWidget {
  final int itemCount;
  const SimpleListSkeleton({super.key, this.itemCount = 8});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 16),
        itemCount: itemCount,
        itemBuilder: (context, index) => ListTile(
          leading: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          title: Container(
            width: double.infinity,
            height: 18.0,
            color: Colors.white,
          ),
          subtitle: Container(
            margin: const EdgeInsets.only(top: 4.0),
            width: 120,
            height: 14.0,
            color: Colors.white,
          ),
        ),
        separatorBuilder: (context, index) => const Divider(height: 1, indent: 16, endIndent: 16),
      ),
    );
  }
}

class DropdownSkeleton extends StatelessWidget {
  const DropdownSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

class StatsCardSkeleton extends StatelessWidget {
  final int cardCount;
  const StatsCardSkeleton({super.key, this.cardCount = 3});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: cardCount,
        itemBuilder: (context, index) => Container(
          margin: const EdgeInsets.only(bottom: 20),
          height: 120,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
} 