import 'package:ansarlogistics/Picker/presentation_layer/features/feature_picker_tabs/bloc/picker_dashboard_tab_cubit.dart';
import 'package:ansarlogistics/Picker/presentation_layer/features/feature_picker_tabs/bloc/picker_dashboard_tab_state.dart';
import 'package:ansarlogistics/Picker/presentation_layer/features/feature_picker_tabs/tabs/not_available_tab.dart';
import 'package:ansarlogistics/Picker/presentation_layer/features/feature_picker_tabs/tabs/on_holded_tab.dart';
import 'package:ansarlogistics/Picker/presentation_layer/features/feature_picker_tabs/tabs/picked_tab.dart';
import 'package:ansarlogistics/Picker/presentation_layer/features/feature_picker_tabs/tabs/to_pick_tab.dart';
import 'package:ansarlogistics/themes/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PickerTabDashboard extends StatefulWidget {
  const PickerTabDashboard({super.key});

  @override
  State<PickerTabDashboard> createState() => _PickerTabDashboardState();
}

class _PickerTabDashboardState extends State<PickerTabDashboard>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;

  String _formatSuborderTitle(
    String suborderId,
    String? preparationLabel,
    String? orderId,
  ) {
    final code = suborderId.toUpperCase();
    final label = preparationLabel?.toUpperCase() ?? '';

    if (label.isNotEmpty) {
      // Remove optional PR prefix and separators
      var l = label.startsWith('PR') ? label.substring(2) : label;
      l = l.replaceAll(RegExp(r'[^A-Z0-9]'), '');

      // Exact CODE + digits
      final m1 = RegExp('^' + RegExp.escape(code) + r'(\d+)$').firstMatch(l);
      if (m1 != null) {
        return '$code-${m1.group(1)}';
      }

      // Anywhere CODE followed by digits
      final m2 = RegExp(RegExp.escape(code) + r'(\d+)').firstMatch(l);
      if (m2 != null) {
        return '$code-${m2.group(1)}';
      }
    }

    // Fallback to orderId digits if available
    final digits = orderId?.replaceAll(RegExp(r'\D'), '');
    if (digits != null && digits.isNotEmpty) {
      return '$code-$digits';
    }

    // Last resort: just the code
    return code;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PickerDashboardTabCubit, PickerDashboardTabState>(
      builder: (context, state) {
        if (state is PickerDashboardTabLoading ||
            state is PickerDashboardTabInitial) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (state is PickerDashboardTabErrorState) {
          return Scaffold(
            appBar: AppBar(title: const Text('Picker Dashboard')),
            body: Center(child: Text(state.message)),
          );
        }

        final s = state as PickerDashboardTabLoadedState;
        Widget body;
        switch (_currentIndex) {
          case 0:
            body = ToPickTab(groups: s.toPickByCategory);
            break;
          case 1:
            body = PickedTab(groups: s.pickedByCategory);
            break;
          case 2:
            body = OnHoldedTab(groups: s.holdedByCategory);
            break;
          case 3:
          default:
            body = NotAvailableTab(groups: s.notAvailableByCategory);
        }

        final titleText = _formatSuborderTitle(
          s.suborderId,
          s.preparationLabel,
          s.orderId,
        );

        return Scaffold(
          appBar: AppBar(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  titleText,
                  style: customTextStyle(
                    fontStyle: FontStyle.BodyM_Bold,
                    color: FontColor.FontPrimary,
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.info_outline, size: 18),
              ],
            ),
            centerTitle: true,
          ),
          body: body,
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (i) => setState(() => _currentIndex = i),
            type: BottomNavigationBarType.fixed,
            selectedItemColor: customColors().fontPrimary,
            unselectedItemColor: customColors().fontSecondary,
            selectedLabelStyle: customTextStyle(
              fontStyle: FontStyle.BodyS_Bold,
              color: FontColor.FontPrimary,
            ),
            unselectedLabelStyle: customTextStyle(
              fontStyle: FontStyle.BodyS_Regular,
              color: FontColor.FontSecondary,
            ),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.list_alt),
                label: 'To pick',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.check_circle),
                label: 'Picked',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.pause_circle_filled),
                label: 'On Hold',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.search_off),
                label: 'Not Available',
              ),
            ],
          ),
        );
      },
    );
  }
}
