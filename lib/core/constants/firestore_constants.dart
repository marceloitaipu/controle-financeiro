// lib/core/constants/firestore_constants.dart

/// Nomes de coleções e campos do Firestore.
/// Garante consistência e evita typos em todo o projeto.
abstract final class FirestoreConstants {
  // ── Coleções raiz ────────────────────────────────────────────────────────
  static const String users = 'users';

  // ── Sub-coleções por usuário ─────────────────────────────────────────────
  static const String accounts = 'accounts';
  static const String categories = 'categories';
  static const String transactions = 'transactions';
  static const String creditCards = 'credit_cards';
  static const String invoices = 'invoices';
  static const String installmentGroups = 'installment_groups';
  static const String goals = 'goals';
  static const String budgets = 'budgets';
  static const String attachments = 'attachments';

  // ── Campos comuns ────────────────────────────────────────────────────────
  static const String fieldId = 'id';
  static const String fieldUserId = 'userId';
  static const String fieldCreatedAt = 'createdAt';
  static const String fieldUpdatedAt = 'updatedAt';
  static const String fieldIsDeleted = 'isDeleted';

  // ── Campos de Transaction ────────────────────────────────────────────────
  static const String fieldType = 'type';
  static const String fieldAmount = 'amount';
  static const String fieldDate = 'date';
  static const String fieldDescription = 'description';
  static const String fieldNotes = 'notes';
  static const String fieldCategoryId = 'categoryId';
  static const String fieldAccountId = 'accountId';
  static const String fieldToAccountId = 'toAccountId';
  static const String fieldCreditCardId = 'creditCardId';
  static const String fieldInvoiceId = 'invoiceId';
  static const String fieldInstallmentGroupId = 'installmentGroupId';
  static const String fieldInstallmentIndex = 'installmentIndex';
  static const String fieldIsPaid = 'isPaid';
  static const String fieldIsRecurring = 'isRecurring';
  static const String fieldRecurrenceRule = 'recurrenceRule';

  // ── Campos de Account ────────────────────────────────────────────────────
  static const String fieldName = 'name';
  static const String fieldBalance = 'balance';
  static const String fieldAccountType = 'accountType';
  static const String fieldColor = 'color';
  static const String fieldIcon = 'icon';
  static const String fieldBankName = 'bankName';
  static const String fieldIsDefault = 'isDefault';
  static const String fieldIncludeInTotal = 'includeInTotal';

  // ── Campos de CreditCard ────────────────────────────────────────────────
  static const String fieldLimit = 'limit';
  static const String fieldClosingDay = 'closingDay';
  static const String fieldDueDay = 'dueDay';
  static const String fieldBrand = 'brand';
  static const String fieldLastFourDigits = 'lastFourDigits';

  // ── Campos de Invoice ───────────────────────────────────────────────────
  static const String fieldYearMonth = 'yearMonth';
  static const String fieldTotalAmount = 'totalAmount';
  static const String fieldStatus = 'status';
  static const String fieldDueDate = 'dueDate';
  static const String fieldClosingDate = 'closingDate';

  // ── Campos de Goal ──────────────────────────────────────────────────────
  static const String fieldTargetAmount = 'targetAmount';
  static const String fieldCurrentAmount = 'currentAmount';
  static const String fieldTargetDate = 'targetDate';
  static const String fieldPriority = 'priority';

  // ── Campos de Budget ────────────────────────────────────────────────────
  static const String fieldLimitAmount = 'limitAmount';
  static const String fieldSpentAmount = 'spentAmount';
  static const String fieldMonth = 'month';
  static const String fieldYear = 'year';
}
