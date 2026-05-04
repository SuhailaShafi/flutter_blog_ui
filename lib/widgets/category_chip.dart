import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../models/category_model.dart';

class CategoryChip extends StatelessWidget {
  final CategoryModel? category; // null = "All"
  final bool isSelected;
  final ValueChanged<String?> onSelected;

  const CategoryChip({
    super.key,
    this.category,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => onSelected(category?.id),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: isSelected
                ? const LinearGradient(colors: AppTheme.primaryGradient)
                : null,
            color: isSelected ? null : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? Colors.transparent
                  : Colors.grey.shade200,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppTheme.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Text(
            category?.name ?? 'All',
            style: TextStyle(
              color: isSelected ? Colors.white : const Color(0xFF4A4A6A),
              fontWeight:
                  isSelected ? FontWeight.w600 : FontWeight.normal,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}
