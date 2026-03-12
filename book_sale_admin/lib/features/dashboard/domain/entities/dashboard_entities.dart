import 'package:equatable/equatable.dart';

class DashboardStats extends Equatable {
  final Map<String, dynamic>? users;
  final Map<String, dynamic>? listings;
  final Map<String, dynamic>? reports;
  final Map<String, dynamic>? charts;

  const DashboardStats({this.users, this.listings, this.reports, this.charts});

  @override
  List<Object?> get props => [users, listings, reports, charts];
}

class ActivityItem extends Equatable {
  final String? title;
  final String? subtitle;
  final String? icon;
  final String? color;
  final String? timestamp;
  final String? type;

  const ActivityItem({
    this.title,
    this.subtitle,
    this.icon,
    this.color,
    this.timestamp,
    this.type,
  });

  @override
  List<Object?> get props => [title, subtitle, icon, color, timestamp, type];
}
