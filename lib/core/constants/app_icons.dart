import 'package:flutter/material.dart';

/// Design system icon tokens extracted from the Google Material Symbols Outlined specification.
/// Contains SVG asset paths, size tokens, and matching Material Symbols Outlined IconData.
class AppIcons {
  // Prevent instantiation
  AppIcons._();

  // ==========================================
  // ICON SIZE TOKENS
  // ==========================================

  /// 16px - Used for inline text & tags
  static const double sizeInline = 16.0;
  static const double s16 = sizeInline;

  /// 20px - Used inside buttons
  static const double sizeButton = 20.0;
  static const double s20 = sizeButton;

  /// 24px - Used for navigation & sidebar items (Default opsz: 24)
  static const double sizeSidebar = 24.0;
  static const double sizeDefault = 24.0;
  static const double s24 = sizeSidebar;

  /// 32px+ - Used for KPI metrics, large cards & banners
  static const double sizeKpi = 32.0;
  static const double s32 = sizeKpi;

  // ==========================================
  // SVG ASSET PATHS (assets/icons/)
  // ==========================================
  static const String _basePath = 'assets/icons';

  // --- 1. Navigation & Menus ---
  static const String dashboardSvg = '$_basePath/dashboard.svg';
  static const String groupSvg = '$_basePath/group.svg';
  static const String schoolSvg = '$_basePath/school.svg';
  static const String menuBookSvg = '$_basePath/menu_book.svg';
  static const String paymentsSvg = '$_basePath/payments.svg';
  static const String settingsSvg = '$_basePath/settings.svg';

  // --- 2. Super Admin & Infra ---
  static const String monitorHeartSvg = '$_basePath/monitor_heart.svg';
  static const String adminPanelSvg = '$_basePath/admin_panel.svg';
  static const String securitySvg = '$_basePath/security.svg';
  static const String databaseSvg = '$_basePath/database.svg';
  static const String historySvg = '$_basePath/history.svg';
  static const String keySvg = '$_basePath/key.svg';

  // --- 3. Academic & Review ---
  static const String pendingActionsSvg = '$_basePath/pending_actions.svg';
  static const String factCheckSvg = '$_basePath/fact_check.svg';
  static const String quizSvg = '$_basePath/quiz.svg';
  static const String assignmentSvg = '$_basePath/assignment.svg';
  static const String analyticsSvg = '$_basePath/analytics.svg';
  static const String editDocumentSvg = '$_basePath/edit_document.svg';

  // --- 4. Kids Gamification & Common ---
  static const String starFillSvg = '$_basePath/star_fill.svg';
  static const String starSvg = '$_basePath/star(fill).svg';
  static const String militaryTechSvg = '$_basePath/military_tech.svg';
  static const String videoGameSvg = '$_basePath/video_game.svg';
  static const String searchSvg = '$_basePath/search.svg';
  static const String notificationsSvg = '$_basePath/notifications.svg';
  static const String fileDownloadSvg = '$_basePath/file_download.svg';

  // ==========================================
  // MATERIAL SYMBOLS OUTLINED (FLUTTER ICONS)
  // ==========================================

  // Navigation & Menus
  static const IconData dashboard = Icons.dashboard_outlined;
  static const IconData group = Icons.group_outlined;
  static const IconData school = Icons.school_outlined;
  static const IconData menuBook = Icons.menu_book_outlined;
  static const IconData payments = Icons.payments_outlined;
  static const IconData settings = Icons.settings_outlined;

  // Super Admin & Infra
  static const IconData monitorHeart = Icons.monitor_heart_outlined;
  static const IconData adminPanel = Icons.admin_panel_settings_outlined;
  static const IconData security = Icons.security_outlined;
  static const IconData database = Icons.storage_outlined;
  static const IconData history = Icons.history_outlined;
  static const IconData key = Icons.key_outlined;

  // Academic & Review
  static const IconData pendingActions = Icons.pending_actions_outlined;
  static const IconData factCheck = Icons.fact_check_outlined;
  static const IconData quiz = Icons.quiz_outlined;
  static const IconData assignment = Icons.assignment_outlined;
  static const IconData analytics = Icons.analytics_outlined;
  static const IconData editDocument = Icons.edit_document;

  // Kids Gamification & Common
  static const IconData starFill = Icons.star;
  static const IconData militaryTech = Icons.military_tech_outlined;
  static const IconData videoGame = Icons.sports_esports_outlined;
  static const IconData search = Icons.search_outlined;
  static const IconData notifications = Icons.notifications_outlined;
  static const IconData fileDownload = Icons.file_download_outlined;
}
