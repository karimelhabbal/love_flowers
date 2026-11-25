import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/di/injection_container.dart' as di;
import '../../../../app/localization/app_strings.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../catalog/domain/repositories/catalog_repository.dart';
import '../../domain/entities/address.dart';
import '../cubit/address_cubit.dart';
import '../cubit/address_state.dart';

class AddressesPage extends StatefulWidget {
  const AddressesPage({super.key});

  @override
  State<AddressesPage> createState() => _AddressesPageState();
}

class _AddressesPageState extends State<AddressesPage> {
  @override
  void initState() {
    super.initState();
    di.sl<AddressCubit>().load();
  }

  Future<void> _showEditor({AddressEntity? address}) async {
    final s = AppStrings.of(context);
    final formKey = GlobalKey<FormState>();
    final label = TextEditingController(
      text: address?.label ?? s.t('homeAddress'),
    );
    final name = TextEditingController(text: address?.fullName ?? '');
    final phone = TextEditingController(text: address?.phone ?? '');
    final city = TextEditingController(
      text: address?.city ?? (s.isArabic ? 'القاهرة' : 'Cairo'),
    );
    final street = TextEditingController(text: address?.street ?? '');
    final building = TextEditingController(text: address?.building ?? '');
    final notes = TextEditingController(text: address?.notes ?? '');
    bool isDefault = address?.isDefault ?? false;

    // checkout_cart requires an address whose zone belongs to the cart branch.
    String? zoneId = address?.zoneId.trim().isEmpty ?? true
        ? null
        : address!.zoneId;
    final branchResult = await di.sl<CatalogRepository>().getBranches();
    final branches = branchResult.valueOrNull ?? const [];
    List<Map<String, dynamic>> zones = const [];
    if (branches.isNotEmpty) {
      final zoneResult = await di.sl<CatalogRepository>().getDeliveryZones(
        branches.first['id'] as String,
      );
      zones = zoneResult.valueOrNull ?? const [];
    }
    if (zoneId == null && zones.isNotEmpty) {
      zoneId = zones.first['id'] as String;
    }
    if (!mounted) {
      for (final controller in [
        label,
        name,
        phone,
        city,
        street,
        building,
        notes,
      ]) {
        controller.dispose();
      }
      return;
    }

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(address == null ? s.t('addAddress') : s.t('editAddress')),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppTextField(
                    label: s.t('label'),
                    controller: label,
                    validator: (value) => Validators.required(
                      value,
                      message: s.t('validationError'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  AppTextField(
                    label: s.t('fullName'),
                    controller: name,
                    validator: (value) => Validators.required(
                      value,
                      message: s.t('validationError'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  AppTextField(
                    label: s.t('phone'),
                    controller: phone,
                    keyboardType: TextInputType.phone,
                    validator: (value) => Validators.phone(
                      value,
                      message: s.t('validationError'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    initialValue: zoneId,
                    decoration: InputDecoration(labelText: s.t('deliveryZone')),
                    validator: (_) =>
                        zoneId == null ? s.t('deliveryZoneRequired') : null,
                    items: [
                      for (final zone in zones)
                        DropdownMenuItem<String>(
                          value: zone['id'] as String,
                          child: Text(
                            s.isArabic
                                ? (zone['name_ar'] as String? ?? '')
                                : (zone['name_en'] as String? ?? ''),
                          ),
                        ),
                    ],
                    onChanged: (value) => setDialogState(() => zoneId = value),
                  ),
                  const SizedBox(height: 10),
                  AppTextField(
                    label: s.t('city'),
                    controller: city,
                    validator: (value) => Validators.required(
                      value,
                      message: s.t('validationError'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  AppTextField(
                    label: s.t('street'),
                    controller: street,
                    validator: (value) => Validators.required(
                      value,
                      message: s.t('validationError'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  AppTextField(label: s.t('building'), controller: building),
                  const SizedBox(height: 10),
                  AppTextField(
                    label: s.t('deliveryInstructions'),
                    controller: notes,
                  ),
                  const SizedBox(height: 6),
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    value: isDefault,
                    onChanged: (value) =>
                        setDialogState(() => isDefault = value ?? false),
                    title: Text(s.t('defaultAddress')),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(s.t('cancel')),
            ),
            TextButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.pop(context, true);
                }
              },
              child: Text(s.t('save')),
            ),
          ],
        ),
      ),
    );

    if (saved == true && zoneId == null && mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(s.t('deliveryZoneRequired'))));
      for (final controller in [
        label,
        name,
        phone,
        city,
        street,
        building,
        notes,
      ]) {
        controller.dispose();
      }
      return;
    }
    if (saved == true) {
      await di.sl<AddressCubit>().save(
        AddressEntity(
          id: address?.id ?? '',
          label: label.text.trim(),
          fullName: name.text.trim(),
          phone: phone.text.trim(),
          city: city.text.trim(),
          street: street.text.trim(),
          building: building.text.trim(),
          notes: notes.text.trim(),
          isDefault: isDefault,
          zoneId: zoneId ?? '',
        ),
      );
    }

    for (final controller in [
      label,
      name,
      phone,
      city,
      street,
      building,
      notes,
    ]) {
      controller.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(s.t('addresses'))),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showEditor(),
        child: const Icon(Icons.add_rounded),
      ),
      body: BlocBuilder<AddressCubit, AddressState>(
        builder: (context, state) {
          if (state.status == AddressStatus.loading ||
              state.status == AddressStatus.initial) {
            return const LoadingView();
          }
          if (state.status == AddressStatus.failure) {
            return ErrorView(
              message: state.message ?? s.t('errorGeneric'),
              onRetry: () => di.sl<AddressCubit>().load(),
            );
          }
          if (state.addresses.isEmpty) {
            return EmptyView(
              title: s.t('addressRequired'),
              subtitle: s.t('addAddress'),
              icon: Icons.location_off_outlined,
              actionLabel: s.t('addAddress'),
              onAction: () => _showEditor(),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 90),
            itemCount: state.addresses.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final address = state.addresses[index];
              return Card(
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.blush,
                    child: Icon(
                      Icons.location_on_outlined,
                      size: 19,
                      color: AppColors.sage,
                    ),
                  ),
                  title: Row(
                    children: [
                      Text(
                        address.label,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      if (address.isDefault) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.sage.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            s.t('defaultAddress'),
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.sage,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  subtitle: Text(
                    '${address.fullName}\n${address.displayLine}\n${address.phone}',
                  ),
                  isThreeLine: true,
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        _showEditor(address: address);
                      } else if (value == 'delete') {
                        di.sl<AddressCubit>().remove(address.id);
                      } else if (value == 'default') {
                        di.sl<AddressCubit>().setDefault(address.id);
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(value: 'edit', child: Text(s.t('edit'))),
                      PopupMenuItem(
                        value: 'default',
                        child: Text(s.t('defaultAddress')),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Text(s.t('delete')),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
