import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/app_constants.dart';
import '../theme/app_colors.dart';
import 'tap_effects.dart';

class AppUtils {
  static String formatDate(DateTime date, {String format = 'dd MMM yyyy'}) {
    return DateFormat(format).format(date);
  }

  static String formatTime(DateTime time) {
    return DateFormat('hh:mm a').format(time);
  }

  static String formatDateTime(DateTime dt) {
    return DateFormat('dd MMM yyyy, hh:mm a').format(dt);
  }

  static String formatMonth(DateTime date) {
    return DateFormat('MMMM yyyy').format(date);
  }

  static String formatCurrency(double amount, {String symbol = '\$'}) {
    return NumberFormat.currency(symbol: symbol, decimalDigits: 2)
        .format(amount);
  }

  static String formatDuration(double hours) {
    final h = hours.floor();
    final m = ((hours - h) * 60).round();
    return '${h}h ${m}m';
  }

  static String getKpiRating(double score) {
    if (score >= AppConstants.kpiExcellentMin) {
      return AppConstants.kpiExcellent;
    }
    if (score >= AppConstants.kpiVeryGoodMin) {
      return AppConstants.kpiVeryGood;
    }
    if (score >= AppConstants.kpiGoodMin) {
      return AppConstants.kpiGood;
    }
    if (score >= AppConstants.kpiNeedsImprovementMin) {
      return AppConstants.kpiNeedsImprovement;
    }
    return AppConstants.kpiPoor;
  }

  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'present':
        return AppColors.present;
      case 'absent':
        return AppColors.absent;
      case 'late':
        return AppColors.late;
      case 'on leave':
        return AppColors.onLeave;
      case 'overtime':
        return AppColors.overtime;
      case 'early out':
        return AppColors.earlyOut;
      case 'missing checkout':
        return AppColors.missingCheckout;
      case 'duty paused':
      case 'paused':
        return AppColors.warning;
      case 'active':
        return AppColors.success;
      case 'inactive':
        return AppColors.error;
      case 'suspended':
        return AppColors.warning;
      case 'approved':
        return AppColors.success;
      case 'rejected':
        return AppColors.error;
      case 'pending':
        return AppColors.warning;
      case 'completed':
        return AppColors.success;
      case 'terminated':
        return AppColors.error;
      case 'visit':
        return AppColors.accent;
      case 'paid':
        return AppColors.success;
      case 'hold':
        return AppColors.warning;
      case 'excellent':
        return AppColors.success;
      case 'very good':
        return AppColors.primaryLight;
      case 'good':
        return AppColors.primary;
      case 'needs improvement':
        return AppColors.warning;
      case 'poor':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  static Color getKpiColor(double score) {
    if (score >= 90) return AppColors.success;
    if (score >= 80) return AppColors.primaryLight;
    if (score >= 70) return AppColors.primary;
    if (score >= 60) return AppColors.warning;
    return AppColors.error;
  }

  static String getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  static double calculateWorkingHours(DateTime checkIn, DateTime checkOut) {
    final diff = checkOut.difference(checkIn);
    return diff.inMinutes / 60.0;
  }

  static double calculateOvertime(double workingHours,
      {double standard = AppConstants.standardShiftHours}) {
    final overtime = workingHours - standard;
    return overtime > 0 ? overtime : 0;
  }

  static int calculateLateMinutes(DateTime checkIn, DateTime shiftStart) {
    if (checkIn.isAfter(shiftStart)) {
      return checkIn.difference(shiftStart).inMinutes;
    }
    return 0;
  }

  static void showSnackBar(BuildContext context, String message,
      {bool isError = false}) {
    if (isError) {
      SoundService.instance.playReject();
    } else {
      SoundService.instance.playConfirm();
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  static Future<bool?> showConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    bool isDangerous = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              SoundService.instance.playClick();
              Navigator.pop(ctx, false);
            },
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () {
              if (isDangerous) {
                SoundService.instance.playReject();
              } else {
                SoundService.instance.playConfirm();
              }
              Navigator.pop(ctx, true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  isDangerous ? AppColors.error : AppColors.primary,
            ),
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }
}
