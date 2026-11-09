import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/validators.dart';
import '../../../core/widgets/feedback.dart';
import '../../../core/widgets/state_views.dart';
import '../../health_records/view/health_metric.dart';
import '../data/daily_goals.dart';
import '../viewmodel/goals_provider.dart';

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GoalsProvider>();
    final goals = provider.goals;
    if (goals == null) {
      return provider.loadError != null
          ? ErrorView(message: provider.loadError!, onRetry: provider.load)
          : const LoadingView();
    }
    return _GoalsForm(key: ValueKey(goals), goals: goals);
  }
}

class _GoalsForm extends StatefulWidget {
  final DailyGoals goals;

  const _GoalsForm({super.key, required this.goals});

  @override
  State<_GoalsForm> createState() => _GoalsFormState();
}

class _GoalsFormState extends State<_GoalsForm> {
  final _formKey = GlobalKey<FormState>();
  late final _controllers = {
    for (final metric in HealthMetric.values)
      metric: TextEditingController(
          text: metric.ofGoals(widget.goals).toString()),
  };
  bool _saving = false;

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  int _value(HealthMetric metric) =>
      int.parse(_controllers[metric]!.text.trim());

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final error = await context.read<GoalsProvider>().save(DailyGoals(
          steps: _value(HealthMetric.steps),
          calories: _value(HealthMetric.calories),
          water: _value(HealthMetric.water),
        ));
    if (!mounted) return;
    setState(() => _saving = false);
    showMessage(context, error ?? 'Goals saved', isError: error != null);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('Daily goals', style: theme.textTheme.titleLarge),
              const SizedBox(height: 4),
              Text(
                'Set a target for each day. The dashboard shows how close '
                'you are to each goal.',
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
              for (final metric in HealthMetric.values) ...[
                const SizedBox(height: 20),
                TextFormField(
                  controller: _controllers[metric],
                  decoration: InputDecoration(
                    labelText: '${metric.label} goal',
                    suffixText: metric.unit,
                    prefixIcon: Icon(metric.icon, color: metric.color),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(6),
                  ],
                  validator: (value) => validateWholeNumber(value,
                      label: '${metric.label} goal', min: 1, max: metric.max),
                ),
              ],
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _saving ? null : _save,
                style:
                    FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
                icon: const Icon(Icons.flag_rounded),
                label: const Text('Save goals'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
