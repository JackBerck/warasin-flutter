import 'package:flutter/material.dart';
import '../../data/models/schedule_model.dart';

class DaySelectorWidget extends StatelessWidget {
  final List<int> selectedDays;
  final Function(List<int>) onChanged;

  const DaySelectorWidget({
    super.key,
    required this.selectedDays,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(7, (index) {
        final day = index + 1; // 1 = Monday, 7 = Sunday
        final isSelected = selectedDays.contains(day);

        return InkWell(
          onTap: () {
            final newSelectedDays = List<int>.from(selectedDays);
            if (isSelected) {
              newSelectedDays.remove(day);
            } else {
              newSelectedDays.add(day);
            }
            newSelectedDays.sort();
            onChanged(newSelectedDays);
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isSelected
                  ? Theme.of(context).primaryColor
                  : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Colors.grey.shade300,
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                Schedule.getShortDayName(day),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : Colors.grey.shade700,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
