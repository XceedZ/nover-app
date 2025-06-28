// lib/components/custom_bank_dropdown.dart

import 'package:flutter/material.dart';
import 'package:nover/src/models/bank.dart';
import 'package:nover/src/utils/app_fonts.dart';
import 'package:nover/src/utils/translation.dart';
import 'package:remixicon/remixicon.dart';

class CustomBankDropdown extends StatelessWidget {
  final String labelText;
  final Bank? value;
  final String hintText;
  final List<Bank> items;
  final IconData prefixIcon;
  final bool isDisabled;
  final ValueChanged<Bank> onChanged;

  const CustomBankDropdown({
    super.key,
    required this.labelText,
    required this.value,
    required this.hintText,
    required this.items,
    required this.onChanged,
    this.prefixIcon = Remix.bank_line,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final textStyle = AppFonts.titleMedium(
      color: value == null ? theme.hintColor : theme.colorScheme.onSurface,
    );
    final iconColor = theme.colorScheme.onSurface.withOpacity(0.6);

    return InkWell(
      onTap: isDisabled
          ? null
          : () async {
        final Bank? selectedBank = await showModalBottomSheet<Bank>(
          context: context,
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (context) => DraggableScrollableSheet(
            initialChildSize: 0.6,
            minChildSize: 0.4,
            maxChildSize: 0.9,
            expand: false,
            builder: (context, scrollController) {
              return _BankSelectionSheet(
                banks: items,
                scrollController: scrollController,
              );
            },
          ),
        );

        if (selectedBank != null) {
          onChanged(selectedBank);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(prefixIcon, color: iconColor),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                value?.bankName ?? hintText,
                style: textStyle,
              ),
            ),
            Icon(Remix.arrow_down_s_line, color: iconColor),
          ],
        ),
      ),
    );
  }
}

class _BankSelectionSheet extends StatefulWidget {
  final List<Bank> banks;
  final ScrollController scrollController;

  const _BankSelectionSheet(
      {required this.banks, required this.scrollController});

  @override
  State<_BankSelectionSheet> createState() => _BankSelectionSheetState();
}

class _BankSelectionSheetState extends State<_BankSelectionSheet> {
  final _searchController = TextEditingController();
  List<Bank> _filteredBanks = [];

  @override
  void initState() {
    super.initState();
    _filteredBanks = widget.banks;
    _searchController.addListener(_filterBanks);
  }

  void _filterBanks() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredBanks = widget.banks
          .where((bank) => bank.bankName.toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterBanks);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: theme.cardColor,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchController,
              style: AppFonts.titleMedium(color: colorScheme.onSurface),
              // --- PERUBAHAN UTAMA: Style Search Field disamakan dengan Input Lain ---
              decoration: InputDecoration(
                // Menggunakan hintText karena ini kolom pencarian
                hintText: tl('searchBank'),
                hintStyle: AppFonts.titleMedium(
                    color: colorScheme.onSurface.withOpacity(0.6)),
                filled: true,
                fillColor: colorScheme.surfaceVariant,
                prefixIcon: Icon(Remix.search_line,
                    color: colorScheme.onSurface.withOpacity(0.6)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colorScheme.primary),
                ),
              ),
              // ------------------------------------------------------------------
            ),
          ),
          // Divider dihilangkan karena sekarang search bar sudah terbungkus rapi
          // Divider(color: theme.dividerColor, height: 1),
          Expanded(
            child: ListView.separated(
              controller: widget.scrollController,
              padding: const EdgeInsets.only(top: 8), // Beri sedikit padding atas
              itemCount: _filteredBanks.length,
              itemBuilder: (context, index) {
                final bank = _filteredBanks[index];
                return ListTile(
                  title: Text(
                    bank.bankName,
                    style:
                    AppFonts.titleMedium(color: theme.colorScheme.onSurface),
                  ),
                  onTap: () {
                    Navigator.of(context).pop(bank);
                  },
                );
              },
              separatorBuilder: (context, index) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Divider(
                  color: theme.dividerColor.withOpacity(0.5),
                  height: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}