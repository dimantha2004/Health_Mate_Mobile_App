import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/formatters.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/feedback.dart';
import '../data/health_record.dart';
import '../viewmodel/health_records_provider.dart';
import 'health_metric.dart';

/// Add a new health record, or edit [record] when one is given.
class RecordFormScreen extends StatefulWidget {
  final HealthRecord? record;

  const RecordFormScreen({super.key, this.record});

  bool get isEditing => record != null;

  @override
  State<RecordFormScreen> createState() => _RecordFormScreenState();
}

class _RecordFormScreenState extends State<RecordFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late DateTime _date = widget.record?.date ?? today();
  late final _dateController =
      TextEditingController(text: formatLongDate(_date));
  late final _controllers = {
    for (final metric in HealthMetric.values)
      metric: TextEditingController(
        text: widget.record == null
            ? ''
            : metric.ofRecord(widget.record!).toString(),
      ),
  };

  bool _saving = false;
  String? _formError;

  /// Errors appear only after the first Save, then update as the user types.
  AutovalidateMode _autovalidate = AutovalidateMode.disabled;

  @override
  void dispose() {
    _dateController.dispose();
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: today(), // future dates cannot be selected
      helpText: 'Select record date',
    );
    if (picked == null) return;
    setState(() {
      _date = picked;
      _dateController.text = formatLongDate(picked);
    });
  }

  Future<void> _save() async {
    setState(() {
      _autovalidate = AutovalidateMode.onUserInteraction;
      _formError = null;
    });
    if (!_formKey.currentState!.validate()) return;

    final values = {
      for (final entry in _controllers.entries)
        entry.key: int.parse(entry.value.text.trim()),
    };
    if (values.values.every((v) => v == 0)) {
      setState(() =>
          _formError = 'Enter at least one activity value greater than 0.');
      return;
    }

    final record = HealthRecord(
      id: widget.record?.id,
      date: _date,
      steps: values[HealthMetric.steps]!,
      calories: values[HealthMetric.calories]!,
      water: values[HealthMetric.water]!,
    );

    setState(() => _saving = true);
    final provider = context.read<HealthRecordsProvider>();
    final error = widget.isEditing
        ? await provider.updateRecord(record)
        : await provider.addRecord(record);
    if (!mounted) return;
    setState(() => _saving = false);

    if (error != null) {
      showMessage(context, error, isError: true);
      return;
    }
    showMessage(context, widget.isEditing ? 'Record updated' : 'Record saved');
    Navigator.pop(context);
  }

  Future<void> _delete() async {
    if (!await confirmDelete(context) || !mounted) return;
    setState(() => _saving = true);
    final error = await context
        .read<HealthRecordsProvider>()
        .deleteRecord(widget.record!.id!);
    if (!mounted) return;
    setState(() => _saving = false);
    showMessage(context, error ?? 'Record deleted', isError: error != null);
    if (error == null) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const metrics = HealthMetric.values;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Record' : 'Add Record'),
        actions: [
          if (widget.isEditing)
            IconButton(
              tooltip: 'Delete record',
              icon: const Icon(Icons.delete_outline_rounded),
              onPressed: _saving ? null : _delete,
            ),
        ],
      ),
      body: SafeArea(
        child: Center(
          // Keeps the form a comfortable width on tablets and landscape.
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Form(
              key: _formKey,
              autovalidateMode: _autovalidate,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    'Enter your activity for the day. You can add several '
                    'entries per day; the dashboard adds them up.',
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _dateController,
                    readOnly: true,
                    onTap: _pickDate,
                    decoration: const InputDecoration(
                      labelText: 'Date',
                      prefixIcon: Icon(Icons.calendar_today_rounded),
                      suffixIcon: Icon(Icons.arrow_drop_down_rounded),
                    ),
                    validator: (_) => validateRecordDate(_date),
                  ),
                  for (final metric in metrics) ...[
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _controllers[metric],
                      decoration: InputDecoration(
                        labelText: metric.label,
                        hintText: '0',
                        suffixText: metric.unit,
                        prefixIcon: Icon(metric.icon, color: metric.color),
                        helperText: 'Max ${metric.format(metric.max)}',
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(6),
                      ],
                      textInputAction: metric == metrics.last
                          ? TextInputAction.done
                          : TextInputAction.next,
                      onFieldSubmitted:
                          metric == metrics.last ? (_) => _save() : null,
                      validator: (value) => validateWholeNumber(value,
                          label: metric.label, max: metric.max),
                    ),
                  ],
                  if (_formError != null) ...[
                    const SizedBox(height: 16),
                    Text(_formError!,
                        style: TextStyle(color: theme.colorScheme.error)),
                  ],
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: _saving ? null : _save,
                    style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(52)),
                    icon: _saving
                        ? const SizedBox.square(
                            dimension: 20,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.check_rounded),
                    label: Text(widget.isEditing ? 'Save changes' : 'Save record'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
