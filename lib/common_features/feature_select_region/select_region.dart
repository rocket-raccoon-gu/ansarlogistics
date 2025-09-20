import 'package:ansarlogistics/common_features/feature_select_region/bloc/select_region_page_cubit.dart';
import 'package:ansarlogistics/common_features/feature_select_region/bloc/select_region_page_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SelectRegionPage extends StatefulWidget {
  const SelectRegionPage({super.key});

  @override
  State<SelectRegionPage> createState() => _SelectRegionPageState();
}

class _SelectRegionPageState extends State<SelectRegionPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Region'), centerTitle: true),
      body: BlocBuilder<SelectRegionPageCubit, SelectRegionPageState>(
        builder: (context, state) {
          if (state is SelectRegionLoadingState) {
            return const Center(child: CircularProgressIndicator());
          }
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Please select your region to continue',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed:
                      () => context.read<SelectRegionPageCubit>().selectRegion(
                        'qatar',
                      ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('QATAR'),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed:
                      () => context.read<SelectRegionPageCubit>().selectRegion(
                        'uae',
                      ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('UAE'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
