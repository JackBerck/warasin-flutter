import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../profile/providers/profile_provider.dart';
import '../../../medicine/providers/medicine_provider.dart';
import '../../../schedule/providers/schedule_provider.dart';
import '../../../health_record/providers/health_record_provider.dart';
import '../../widgets/dashboard_stat_card.dart';
import '../../widgets/animated_greeting.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = DateTime.now();
    final dateFormat = DateFormat('EEEE, dd MMMM yyyy', 'id_ID');
    final userProfile = ref.watch(userProfileProvider);
    final medicinesAsync = ref.watch(medicineListProvider);
    final schedulesAsync = ref.watch(scheduleListProvider);
    final healthStatsAsync = ref.watch(healthRecordStatisticsProvider);
    final healthRecordsAsync = ref.watch(healthRecordListProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(userProfileProvider);
        ref.invalidate(medicineListProvider);
        ref.invalidate(scheduleListProvider);
        ref.invalidate(healthRecordListProvider);
        ref.invalidate(healthRecordStatisticsProvider);
      },
      child: SingleChildScrollView(
        child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 48, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // GREETING SECTION WITH ANIMATION
              userProfile.when(
                data: (user) => AnimatedGreeting(
                  userName: user?.name ?? 'User',
                  date: dateFormat.format(today),
                ),
                loading: () =>
                    const AnimatedGreeting(userName: 'User', date: '...'),
                error: (_, __) =>
                    const AnimatedGreeting(userName: 'User', date: ''),
              ),

              const SizedBox(height: 20),

              // STATISTICS SECTION
              healthStatsAsync.when(
                data: (stats) => DashboardStatCard(statistics: stats),
                loading: () => const DashboardStatCard(
                  statistics: {
                    "totalRecords": 0,
                    "avgBloodPressureSystolic": 0,
                    "avgBloodPressureDiastolic": 0,
                    "avgBloodSugar": 0,
                  },
                ),
                error: (_, __) => const DashboardStatCard(
                  statistics: {
                    "totalRecords": 0,
                    "avgBloodPressureSystolic": 0,
                    "avgBloodPressureDiastolic": 0,
                    "avgBloodSugar": 0,
                  },
                ),
              ),

              const SizedBox(height: 18),

              // TODAY'S UPCOMING SCHEDULE
              schedulesAsync.when(
                data: (schedules) {
                  final weekday = today.weekday;
                  final todaySchedules = schedules
                      .where((s) => s.isActive && s.days.contains(weekday))
                      .toList();

                  todaySchedules.sort(
                    (a, b) => a.time.hour != b.time.hour
                        ? a.time.hour.compareTo(b.time.hour)
                        : a.time.minute.compareTo(b.time.minute),
                  );

                  return todaySchedules.isEmpty
                      ? _buildEmptySection("Belum ada jadwal obat hari ini 🕐")
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time_filled,
                                  color: Colors.orange.shade600,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "Jadwal Hari Ini",
                                  style: _sectionTitleStyle,
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            ...todaySchedules
                                .take(3)
                                .map(
                                  (s) => _buildMedicineScheduleTile(context, s),
                                ),
                            if (todaySchedules.length > 3)
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: 4,
                                  bottom: 8,
                                  left: 16,
                                ),
                                child: Text(
                                  "+${todaySchedules.length - 3} jadwal lainnya...",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ),
                          ],
                        );
                },
                loading: () => _buildLoadingSection(),
                error: (_, __) =>
                    _buildEmptySection("Tidak dapat memuat jadwal"),
              ),

              const SizedBox(height: 18),

              // LAST HEALTH RECORD - IMPROVED STRUCTURE
              healthRecordsAsync.when(
                data: (records) {
                  if (records.isEmpty) {
                    return _buildEmptySection("Belum ada catatan kesehatan 💚");
                  }
                  final last = records.first;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.favorite,
                            color: Colors.pink.shade400,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "Catatan Kesehatan Terbaru",
                            style: _sectionTitleStyle,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // IMPROVED CARD STRUCTURE
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.pink.shade50, Colors.red.shade50],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.pink.shade100,
                            width: 1,
                          ),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Tanggal
                            Row(
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  size: 14,
                                  color: Colors.grey.shade600,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  DateFormat(
                                    'dd MMM yyyy',
                                    'id_ID',
                                  ).format(last.date),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            // Tekanan Darah
                            if (last.bloodPressureSystolic != null)
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.7),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.favorite,
                                      color: Colors.red.shade400,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Tekanan Darah",
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade700,
                                          ),
                                        ),
                                        Text(
                                          last.bloodPressureFormatted ?? "-",
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _healthStatusColor(
                                        last.bloodPressureStatus,
                                      ).withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: _healthStatusColor(
                                          last.bloodPressureStatus,
                                        ),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Text(
                                      last.bloodPressureStatus,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: _healthStatusColor(
                                          last.bloodPressureStatus,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                            // Gula Darah
                            if (last.bloodSugar != null) ...[
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.7),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.water_drop,
                                      color: Colors.blue.shade400,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Gula Darah",
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade700,
                                          ),
                                        ),
                                        Text(
                                          "${last.bloodSugar!.toStringAsFixed(0)} mg/dL",
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getBloodSugarColor(
                                        last.bloodSugar!,
                                      ).withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: _getBloodSugarColor(
                                          last.bloodSugar!,
                                        ),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Text(
                                      last.bloodSugarStatus,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: _getBloodSugarColor(
                                          last.bloodSugar!,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  );
                },
                loading: () => _buildLoadingSection(),
                error: (_, __) =>
                    _buildEmptySection("Tidak dapat memuat data kesehatan"),
              ),

              const SizedBox(height: 24),

              // QUICK ACTIONS
              _buildQuickActionSection(context),

              const SizedBox(height: 24),

              // SHORTCUTS - GRID MENU (WARNA LEBIH CERAH)
              _buildShortcutMenu(context),

              const SizedBox(height: 44),
            ],
          ),
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "pagi";
    if (hour < 16) return "siang";
    if (hour < 19) return "sore";
    return "malam";
  }

  Color _healthStatusColor(String status) {
    switch (status) {
      case 'Normal':
        return Colors.green.shade600;
      case 'Elevated':
        return Colors.blue.shade600;
      case 'Hipertensi Tahap 1':
        return Colors.orange.shade600;
      case 'Hipertensi Tahap 2':
      case 'Krisis Hipertensi':
        return Colors.red.shade600;
      default:
        return Colors.grey;
    }
  }

  Color _getBloodSugarColor(double value) {
    if (value < 70) return Colors.orange.shade600;
    if (value <= 140) return Colors.green.shade600;
    if (value <= 200) return Colors.orange.shade600;
    return Colors.red.shade600;
  }

  Widget _buildQuickActionSection(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _QuickActionButton(
          icon: Icons.favorite_border,
          label: 'Tambah\nKesehatan',
          gradient: LinearGradient(
            colors: [Colors.pink.shade300, Colors.pink.shade500],
          ),
          onTap: () => context.pushNamed('add-health-record'),
        ),
        _QuickActionButton(
          icon: Icons.access_alarm,
          label: 'Tambah\nJadwal',
          gradient: LinearGradient(
            colors: [Colors.orange.shade300, Colors.orange.shade500],
          ),
          onTap: () => context.pushNamed('schedules'),
        ),
        _QuickActionButton(
          icon: Icons.medication,
          label: 'Tambah\nObat',
          gradient: LinearGradient(
            colors: [Colors.green.shade300, Colors.green.shade500],
          ),
          onTap: () => context.pushNamed('add-medicine'),
        ),
      ],
    );
  }

  Widget _buildMedicineScheduleTile(BuildContext context, schedule) {
    final timeString =
        "${schedule.time.hour.toString().padLeft(2, '0')}:${schedule.time.minute.toString().padLeft(2, '0')}";
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange.shade50, Colors.amber.shade50],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200, width: 1),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.orange.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.access_time,
            color: Colors.orange.shade700,
            size: 20,
          ),
        ),
        title: Text(
          schedule.medicine?.name ?? "Obat",
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(timeString),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 14,
          color: Colors.grey.shade400,
        ),
      ),
    );
  }

  Widget _buildShortcutMenu(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _ShortcutMenuItem(
          icon: Icons.favorite_outline,
          gradient: LinearGradient(
            colors: [Colors.pink.shade100, Colors.pink.shade200],
          ),
          iconColor: Colors.pink.shade700,
          label: 'Kesehatan',
          onTap: () => context.push('/health-records'),
        ),
        _ShortcutMenuItem(
          icon: Icons.medication_outlined,
          gradient: LinearGradient(
            colors: [Colors.green.shade100, Colors.green.shade200],
          ),
          iconColor: Colors.green.shade700,
          label: 'Obat',
          onTap: () => context.push('/medicines'),
        ),
        _ShortcutMenuItem(
          icon: Icons.access_alarms,
          gradient: LinearGradient(
            colors: [Colors.orange.shade100, Colors.orange.shade200],
          ),
          iconColor: Colors.orange.shade700,
          label: 'Jadwal',
          onTap: () => context.push('/schedules'),
        ),
      ],
    );
  }

  Widget _buildLoadingSection() =>
      const Center(child: CircularProgressIndicator());

  Widget _buildEmptySection(String message) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 14),
    child: Center(
      child: Text(
        message,
        style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
      ),
    ),
  );

  final _sectionTitleStyle = const TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 16,
  );
}

// Quick Action Button with Gradient
class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Gradient gradient;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            padding: const EdgeInsets.all(14),
            child: Icon(icon, size: 28, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade800,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

// Shortcuts grid with Gradient
class _ShortcutMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Gradient gradient;
  final Color iconColor;
  final VoidCallback onTap;

  const _ShortcutMenuItem({
    required this.icon,
    required this.label,
    required this.gradient,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 32, color: iconColor),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: iconColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
