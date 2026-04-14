import 'dart:io';
import 'package:bill_mate/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_strings.dart';
import '../../../data/models/bill_model.dart';
import '../../core/constants/app_sizes.dart';
import 'bloc/add_edit_bill_bloc.dart';
import 'bloc/add_edit_bill_event.dart';
import 'bloc/add_edit_bill_state.dart';

class AddBillScreen extends StatefulWidget {
  final BillModel? bill;

  const AddBillScreen({super.key, this.bill});

  bool get isEdit => bill != null;

  @override
  State<AddBillScreen> createState() => _AddBillScreenState();
}

class _AddBillScreenState extends State<AddBillScreen> {
  final _formKey          = GlobalKey<FormState>();
  late final TextEditingController nameController;
  late final TextEditingController amountController;

  DateTime? selectedDate;
  String?   _dateError;
  late String selectedCategory;
  late String selectedRemind;
  late String selectedRepeat;

  @override
  void initState() {
    super.initState();
    final b = widget.bill;
    nameController   = TextEditingController(text: b?.name ?? '');
    amountController = TextEditingController(
        text: b != null ? b.amount.toStringAsFixed(0) : '');
    selectedDate     = b?.dueDate;
    selectedCategory = b?.category     ?? AppStrings.categories.first;
    selectedRemind   = b?.remindBefore ?? AppStrings.remindOptions.first;
    selectedRepeat   = b?.repeat       ?? AppStrings.repeatOptions.first;
  }

  @override
  void dispose() {
    nameController.dispose();
    amountController.dispose();
    super.dispose();
  }

  // ── Image sheet ──────────────────────────────────────────────────────────

  void _showImageSourceSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text("Take Photo"),
              onTap: () {
                Navigator.pop(context);
                context.read<BillFormBloc>()
                    .add(PickImageEvent(ImageSource.camera));
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text("Choose from Gallery"),
              onTap: () {
                Navigator.pop(context);
                context.read<BillFormBloc>()
                    .add(PickImageEvent(ImageSource.gallery));
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // ── Submit ───────────────────────────────────────────────────────────────

  void _submit(BuildContext context) {
    final isFormValid = _formKey.currentState!.validate();

    if (selectedDate == null) {
      setState(() => _dateError = 'Please select a due date');
    } else {
      setState(() => _dateError = null);
    }

    if (!isFormValid || selectedDate == null) return;

    final bloc = context.read<BillFormBloc>();
    context.read<BillFormBloc>().add(
      SaveBillEvent(
        isEdit: widget.isEdit,
        bill: BillModel(
          id:           widget.bill?.id ?? const Uuid().v4(),
          name:         nameController.text.trim(),
          amount:       double.tryParse(amountController.text) ?? 0,
          dueDate:      selectedDate!,
          category:     selectedCategory,
          isPaid:       widget.bill?.isPaid ?? false,
          remindBefore: selectedRemind,
          repeat:       selectedRepeat,
          photoPath:    bloc.currentPhotoPath,
          createdAt:    widget.bill?.createdAt ?? DateTime.now(),
        ),
      ),
    );
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => BillFormBloc(initialPhotoPath: widget.bill?.photoPath),
      child: Builder(
        builder: (context) {
          return BlocConsumer<BillFormBloc, BillFormState>(
            listener: (context, state) {
              if (state is BillFormSuccess) {
                Navigator.pop(context, true);
              } else if (state is BillFormError) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(state.message)));
              }
            },
            builder: (context, state) {
              final isLoading = state is BillFormLoading;
              final photoPath = state is BillFormUpdated
                  ? state.photoPath
                  : widget.bill?.photoPath;

              return Scaffold(
                body: Column(
                  children: [
                    TopBar(title: widget.isEdit ? "Edit Bill" : "Add Bill"),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                              // ── Bill Name ──────────────────────────────
                              const Text("Bill Name"),
                              const SizedBox(height: 5),
                              TextFormField(
                                controller: nameController,
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) {
                                    return 'Bill name is required';
                                  }
                                  if (v.trim().length < 2) {
                                    return 'Name must be at least 2 characters';
                                  }
                                  return null;
                                },
                                decoration: const InputDecoration(
                                  hintText: "Electricity bill",
                                  border: OutlineInputBorder(),
                                ),
                              ),

                              const SizedBox(height: 20),

                              // ── Amount ─────────────────────────────────
                              const Text("Amount"),
                              const SizedBox(height: 5),
                              TextFormField(
                                controller: amountController,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) {
                                    return 'Amount is required';
                                  }
                                  final parsed = double.tryParse(v);
                                  if (parsed == null || parsed <= 0) {
                                    return 'Enter a valid amount';
                                  }
                                  return null;
                                },
                                decoration: const InputDecoration(
                                  hintText: "0",
                                  border: OutlineInputBorder(),
                                ),
                              ),

                              const SizedBox(height: 20),

                              // ── Photo ──────────────────────────────────
                              const Text("Bill Photo (Optional)"),
                              const SizedBox(height: 5),
                              GestureDetector(
                                onTap: () => _showImageSourceSheet(context),
                                child: Container(
                                  height: 150,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: photoPath != null
                                      ? ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: Image.file(
                                      File(photoPath),
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                      : const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.add_a_photo,
                                          size: 40, color: Colors.grey),
                                      SizedBox(height: 8),
                                      Text("Tap to add photo",
                                          style: TextStyle(color: Colors.grey)),
                                    ],
                                  ),
                                ),
                              ),
                              if (photoPath != null)
                                TextButton.icon(
                                  onPressed: () => context
                                      .read<BillFormBloc>()
                                      .add(RemoveImageEvent()),
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  label: const Text("Remove Photo",
                                      style: TextStyle(color: Colors.red)),
                                ),

                              const SizedBox(height: 20),

                              // ── Due Date ───────────────────────────────
                              DateField(
                                selected: selectedDate,
                                errorText: _dateError,
                                onPicked: (date) => setState(() {
                                  selectedDate = date;
                                  _dateError   = null;
                                }),
                              ),

                              const SizedBox(height: 20),

                              // ── Category ───────────────────────────────
                              ChipGroup(
                                label: "Category",
                                options: AppStrings.categories,
                                selected: selectedCategory,
                                onSelected: (v) =>
                                    setState(() => selectedCategory = v),
                              ),

                              const SizedBox(height: 20),

                              // ── Remind Me ──────────────────────────────
                              ChipGroup(
                                label: "Remind Me",
                                options: AppStrings.remindOptions,
                                selected: selectedRemind,
                                onSelected: (v) =>
                                    setState(() => selectedRemind = v),
                              ),

                              const SizedBox(height: 20),

                              // ── Repeat ─────────────────────────────────
                              ChipGroup(
                                label: "Repeat",
                                options: AppStrings.repeatOptions,
                                selected: selectedRepeat,
                                onSelected: (v) =>
                                    setState(() => selectedRepeat = v),
                              ),

                              const SizedBox(height: 40),

                              // ── Save Button ────────────────────────────
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: isLoading
                                      ? null
                                      : () => _submit(context),
                                  child: isLoading
                                      ? const SizedBox(
                                    height: 20, width: 20,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  )
                                      : Text(widget.isEdit
                                      ? "Update Bill"
                                      : "Save Bill"),
                                ),
                              ),

                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ── TopBar ─────────────────────────────────────────────────────────────────

class TopBar extends StatelessWidget {
  final String title;
  const TopBar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primary,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        bottom: 20,
        left: 10,
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: AppSizes.fontXl,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ── DateField ──────────────────────────────────────────────────────────────

class DateField extends StatelessWidget {
  final DateTime? selected;
  final String?   errorText;
  final Function(DateTime) onPicked;

  const DateField({
    super.key,
    required this.selected,
    required this.onPicked,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Due Date"),
        const SizedBox(height: 5),
        GestureDetector(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: selected ?? DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (date != null) onPicked(date);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            decoration: BoxDecoration(
              border: Border.all(
                color: errorText != null ? Colors.red : Colors.grey,
              ),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selected == null
                      ? "Select date"
                      : selected.toString().split(" ")[0],
                  style: TextStyle(
                    color: selected == null ? Colors.grey : Colors.black,
                  ),
                ),
                const Icon(Icons.calendar_today),
              ],
            ),
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 12),
            child: Text(
              errorText!,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }
}

// ── ChipGroup ──────────────────────────────────────────────────────────────

class ChipGroup extends StatelessWidget {
  final String label;
  final List<String> options;
  final String selected;
  final Function(String) onSelected;

  const ChipGroup({
    super.key,
    required this.label,
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          children: options.map((option) {
            return ChoiceChip(
              label: Text(option),
              selected: option == selected,
              onSelected: (_) => onSelected(option),
            );
          }).toList(),
        ),
      ],
    );
  }
}