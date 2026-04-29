// lib/core/theme/app_icons.dart

import 'package:flutter/material.dart';

/// Constantes de ícones do aplicativo.
///
/// Centraliza os ícones usados em todo o app para garantir consistência.
/// Quando trocar a fonte de ícones (ex: de Icons para Phosphor), edita-se
/// apenas este arquivo.
abstract final class AppIcons {
  // ── Navegação ────────────────────────────────────────────────────────────
  static const IconData home = Icons.home_rounded;
  static const IconData homeOutlined = Icons.home_outlined;
  static const IconData transactions = Icons.receipt_long_rounded;
  static const IconData transactionsOutlined = Icons.receipt_long_outlined;
  static const IconData creditCards = Icons.credit_card_rounded;
  static const IconData creditCardsOutlined = Icons.credit_card_outlined;
  static const IconData reports = Icons.bar_chart_rounded;
  static const IconData reportsOutlined = Icons.bar_chart_outlined;
  static const IconData settings = Icons.settings_rounded;
  static const IconData settingsOutlined = Icons.settings_outlined;

  // ── Transações ──────────────────────────────────────────────────────────
  static const IconData income = Icons.arrow_downward_rounded;
  static const IconData expense = Icons.arrow_upward_rounded;
  static const IconData transfer = Icons.swap_horiz_rounded;
  static const IconData add = Icons.add_rounded;
  static const IconData addCircle = Icons.add_circle_outline_rounded;
  static const IconData removeCircle = Icons.remove_circle_outline_rounded;

  // ── Contas ──────────────────────────────────────────────────────────────
  static const IconData account = Icons.account_balance_rounded;
  static const IconData accountOutlined = Icons.account_balance_outlined;
  static const IconData wallet = Icons.account_balance_wallet_rounded;
  static const IconData walletOutlined = Icons.account_balance_wallet_outlined;
  static const IconData piggyBank = Icons.savings_rounded;
  static const IconData investment = Icons.trending_up_rounded;

  // ── Categorias ──────────────────────────────────────────────────────────
  static const IconData category = Icons.category_rounded;
  static const IconData food = Icons.restaurant_rounded;
  static const IconData transport = Icons.directions_car_rounded;
  static const IconData health = Icons.favorite_rounded;
  static const IconData leisure = Icons.sports_esports_rounded;
  static const IconData education = Icons.school_rounded;
  static const IconData housing = Icons.home_work_rounded;
  static const IconData shopping = Icons.shopping_bag_rounded;
  static const IconData salary = Icons.work_rounded;
  static const IconData other = Icons.more_horiz_rounded;

  // ── Metas / Orçamentos ──────────────────────────────────────────────────
  static const IconData goal = Icons.flag_rounded;
  static const IconData budget = Icons.pie_chart_rounded;
  static const IconData budgetOutlined = Icons.pie_chart_outline_rounded;
  static const IconData insights = Icons.auto_awesome_rounded;

  // ── Ações comuns ────────────────────────────────────────────────────────
  static const IconData edit = Icons.edit_rounded;
  static const IconData delete = Icons.delete_outline_rounded;
  static const IconData search = Icons.search_rounded;
  static const IconData filter = Icons.tune_rounded;
  static const IconData sort = Icons.sort_rounded;
  static const IconData more = Icons.more_vert_rounded;
  static const IconData share = Icons.share_rounded;
  static const IconData download = Icons.download_rounded;
  static const IconData attach = Icons.attach_file_rounded;
  static const IconData camera = Icons.camera_alt_rounded;
  static const IconData image = Icons.image_rounded;
  static const IconData check = Icons.check_rounded;
  static const IconData checkCircle = Icons.check_circle_rounded;
  static const IconData close = Icons.close_rounded;
  static const IconData back = Icons.arrow_back_rounded;
  static const IconData forward = Icons.arrow_forward_rounded;
  static const IconData chevronRight = Icons.chevron_right_rounded;
  static const IconData chevronLeft = Icons.chevron_left_rounded;
  static const IconData chevronDown = Icons.keyboard_arrow_down_rounded;
  static const IconData chevronUp = Icons.keyboard_arrow_up_rounded;
  static const IconData copy = Icons.copy_rounded;
  static const IconData visibility = Icons.visibility_rounded;
  static const IconData visibilityOff = Icons.visibility_off_rounded;
  static const IconData refresh = Icons.refresh_rounded;
  static const IconData info = Icons.info_outline_rounded;
  static const IconData warning = Icons.warning_amber_rounded;
  static const IconData error = Icons.error_outline_rounded;
  static const IconData notifications = Icons.notifications_outlined;
  static const IconData calendar = Icons.calendar_today_rounded;
  static const IconData calendarMonth = Icons.calendar_month_rounded;
  static const IconData clock = Icons.access_time_rounded;
  static const IconData person = Icons.person_rounded;
  static const IconData personOutlined = Icons.person_outline_rounded;
  static const IconData logout = Icons.logout_rounded;
  static const IconData darkMode = Icons.dark_mode_rounded;
  static const IconData lightMode = Icons.light_mode_rounded;

  // ── Mapa ícone → dados de conta ──────────────────────────────────────────
  static const Map<String, IconData> accountTypeIcons = {
    'checking': account,
    'savings': piggyBank,
    'wallet': wallet,
    'investment': investment,
    'credit': creditCards,
  };

  /// Ícones disponíveis para personalização de categorias.
  static const List<IconData> categoryIcons = [
    food, transport, health, leisure, education,
    housing, shopping, salary, investment, other,
    Icons.local_gas_station_rounded,
    Icons.phone_android_rounded,
    Icons.flight_rounded,
    Icons.hotel_rounded,
    Icons.child_care_rounded,
    Icons.pets_rounded,
    Icons.fitness_center_rounded,
    Icons.local_pharmacy_rounded,
    Icons.subscriptions_rounded,
    Icons.volunteer_activism_rounded,
  ];
}
