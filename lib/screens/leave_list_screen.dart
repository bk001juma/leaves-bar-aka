import 'package:flutter/material.dart';
import '../models/leaves_model.dart';
import '../services/api_service.dart';
import 'add_leaves_screen.dart';
import 'login_screen.dart';

class LeaveListScreen extends StatefulWidget {
  const LeaveListScreen({super.key});

  @override
  State<LeaveListScreen> createState() => _LeaveListScreenState();
}

class _LeaveListScreenState extends State<LeaveListScreen> {
  List<Leave> _leaves = [];
  bool _loading = true;
  String? _error;

  static const _primaryColor = Colors.orange;
  static const _bgColor = Colors.blueGrey;

  @override
  void initState() {
    super.initState();
    _fetchLeaves();
  }

  Future<void> _fetchLeaves() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await ApiService.getLeaves();
      if (res['code'] == 200) {
        final data = res['data'] as List<dynamic>;
        setState(() {
          _leaves = data.map((e) => Leave.fromJson(e as Map<String, dynamic>)).toList();
        });
      } else {
        setState(() => _error = res['message']?.toString() ?? 'Failed to load leaves');
      }
    } catch (e) {
      setState(() => _error = 'Could not connect to server.');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _deleteLeave(int id) async {
    try {
      final res = await ApiService.deleteLeave(id);
      if (res['code'] == 200) {
        setState(() => _leaves.removeWhere((l) => l.id == id));
        _showSnack('Leave deleted', Colors.green);
      } else {
        _showSnack(res['message']?.toString() ?? 'Delete failed', Colors.redAccent);
      }
    } catch (e) {
      _showSnack('Could not connect to server.', Colors.redAccent);
    }
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  IconData _statusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Icons.check_circle_outline;
      case 'rejected':
        return Icons.cancel_outlined;
      default:
        return Icons.hourglass_empty_rounded;
    }
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        backgroundColor: _bgColor,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'My Leaves',
          style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0.5),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Logout',
            onPressed: () async {
              await ApiService.clearToken();
              if (!mounted) return;
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.wifi_off_rounded, color: Colors.white54, size: 48),
                      const SizedBox(height: 12),
                      Text(_error!, style: const TextStyle(color: Colors.white70)),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _fetchLeaves,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryColor,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _fetchLeaves,
                  color: _primaryColor,
                  child: _leaves.isEmpty
                      ? ListView(
                          children: const [
                            SizedBox(height: 120),
                            Center(
                              child: Column(
                                children: [
                                  Icon(Icons.event_busy_rounded,
                                      color: Colors.white38, size: 64),
                                  SizedBox(height: 16),
                                  Text(
                                    'No leaves yet',
                                    style: TextStyle(
                                        color: Colors.white60,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  SizedBox(height: 6),
                                  Text(
                                    'Tap + to apply for a leave',
                                    style: TextStyle(color: Colors.white38, fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                          itemCount: _leaves.length,
                          itemBuilder: (context, index) {
                            final leave = _leaves[index];
                            final statusColor = _statusColor(leave.status);
                            return Dismissible(
                              key: Key(leave.id.toString()),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade400,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 20),
                                child: const Icon(Icons.delete_outline_rounded,
                                    color: Colors.white, size: 28),
                              ),
                              confirmDismiss: (_) async {
                                return await showDialog<bool>(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: const Text('Delete Leave'),
                                    content: const Text(
                                        'Are you sure you want to delete this leave request?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, false),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, true),
                                        child: const Text('Delete',
                                            style: TextStyle(color: Colors.red)),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              onDismissed: (_) => _deleteLeave(leave.id),
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.08),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              leave.reason,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 15,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: statusColor.withOpacity(0.12),
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(_statusIcon(leave.status),
                                                    size: 13, color: statusColor),
                                                const SizedBox(width: 4),
                                                Text(
                                                  leave.status[0].toUpperCase() +
                                                      leave.status.substring(1),
                                                  style: TextStyle(
                                                    color: statusColor,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      Row(
                                        children: [
                                          const Icon(Icons.calendar_today_outlined,
                                              size: 13, color: Colors.grey),
                                          const SizedBox(width: 5),
                                          Text(
                                            '${_formatDate(leave.startDate)}  →  ${_formatDate(leave.endDate)}',
                                            style: const TextStyle(
                                                color: Colors.grey, fontSize: 13),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final added = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (_) => const AddLeaveScreen()),
          );
          if (added == true) _fetchLeaves();
        },
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Apply Leave', style: TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }
}
