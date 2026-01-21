import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import 'providers/admin_provider.dart';
import 'package:fl_chart/fl_chart.dart';

class AdminDashboard extends ConsumerWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(adminStatsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        title: const Text('Dashboard'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Logout',
            onPressed: () async {
              await ApiClient().clearToken();
              Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.primaryColor.withOpacity(0.8),
              // Colors.purple.shade600.withOpacity(0.3),
              theme.scaffoldBackgroundColor,
            ],
          ),
        ),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: () => ref.refresh(adminStatsProvider.future),
            child: statsAsync.when(
              data: (stats) => SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Text(
                      'Platform Overview',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Real-time statistics and insights',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Stats Grid
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 1.4,
                      children: [
                        _buildStatCard('Total Projects', stats.totalProjects.toString(), Icons.folder_special, Colors.blue),
                        _buildStatCard('Total Tasks', stats.totalTasks.toString(), Icons.task_alt, Colors.orange),
                        _buildStatCard('Completed Tasks', stats.completedTasks.toString(), Icons.check_circle, Colors.green),
                        _buildStatCard('Pending Payments', stats.pendingPayments.toString(), Icons.schedule, Colors.amber),
                        _buildStatCard('Total Revenue', '\$${stats.totalRevenue.toStringAsFixed(2)}', Icons.account_balance_wallet, Colors.purple),
                        _buildStatCard('Hours Logged', stats.totalHoursLogged.toStringAsFixed(1), Icons.timer, Colors.teal),
                        _buildStatCard('Active Buyers', stats.totalBuyers.toString(), Icons.people, Colors.indigo),
                        _buildStatCard('Active Developers', stats.totalDevelopers.toString(), Icons.code, Colors.cyan),
                      ],
                    ),

                    const SizedBox(height: 40),

                    // Task Status Distribution Chart
                    Card(
                      elevation: 12,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Task Status Distribution',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              height: 260,
                              child: PieChart(
                                PieChartData(
                                  sectionsSpace: 4,
                                  centerSpaceRadius: 50,
                                  sections: [
                                    PieChartSectionData(
                                      color: Colors.grey,
                                      value: (stats.totalTasks - stats.completedTasks).toDouble(),
                                      title: 'In Progress',
                                      radius: 70,
                                      titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                                    ),
                                    PieChartSectionData(
                                      color: Colors.amber,
                                      value: stats.pendingPayments.toDouble(),
                                      title: 'Submitted',
                                      radius: 70,
                                      titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                                    ),
                                    PieChartSectionData(
                                      color: Colors.green,
                                      value: (stats.completedTasks - stats.pendingPayments).toDouble(),
                                      title: 'Paid',
                                      radius: 70,
                                      titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                                    ),
                                  ],
                                  pieTouchData: PieTouchData(
                                    touchCallback: (FlTouchEvent event, pieTouchResponse) {
                                      // Optional: show tooltip on touch
                                    },
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            // Legend
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildLegendItem(Colors.grey, 'In Progress'),
                                const SizedBox(width: 20),
                                _buildLegendItem(Colors.amber, 'Submitted'),
                                const SizedBox(width: 20),
                                _buildLegendItem(Colors.green, 'Paid'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
              loading: () => const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
              error: (err, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 80, color: Colors.white.withOpacity(0.8)),
                    const SizedBox(height: 16),
                    Text('Error loading data', style: TextStyle(fontSize: 18, color: Colors.white)),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () => ref.refresh(adminStatsProvider),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 30, color: Colors.white),
          const SizedBox(height: 5),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 15, color: Colors.white70),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(color: Colors.black87, fontSize: 14)),
      ],
    );
  }
}