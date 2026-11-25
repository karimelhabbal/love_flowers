import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../app/di/injection_container.dart' as di;
import '../../../app/localization/app_strings.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/widgets/app_image.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/state_views.dart';
import '../../../features/auth/domain/entities/app_user.dart';
import '../../../features/catalog/domain/entities/category.dart';
import '../../../features/catalog/domain/entities/product.dart';
import '../../../features/orders/domain/entities/order.dart';
import '../cubit/admin_cubit.dart';
import '../cubit/admin_state.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  int _index = 0;

  static const _icons = [
    Icons.dashboard_outlined,
    Icons.local_florist_outlined,
    Icons.category_outlined,
    Icons.receipt_long_outlined,
    Icons.people_outline_rounded,
    Icons.inventory_2_outlined,
  ];

  static const _labels = [
    'dashboard',
    'products',
    'categories',
    'orders',
    'customers',
    'inventory',
  ];

  void _loadSection(int index) {
    final cubit = di.sl<AdminCubit>();
    switch (index) {
      case 0:
        cubit.loadDashboard();
      case 1:
        cubit.loadProducts();
      case 2:
        cubit.loadCategories();
      case 3:
        cubit.loadOrders();
      case 4:
        cubit.loadCustomers();
      case 5:
        cubit.loadProducts();
    }
  }

  @override
  void initState() {
    super.initState();
    _loadSection(0);
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final wide = MediaQuery.sizeOf(context).width >= 900;

    return Scaffold(
      appBar: AppBar(
        title: Text('${s.t('dashboard')} · Love Flowers'),
        actions: [
          IconButton(
            onPressed: () => context.go('/home'),
            icon: const Icon(Icons.storefront_outlined),
            tooltip: s.t('shop'),
          ),
        ],
      ),
      body: Row(
        children: [
          if (wide)
            NavigationRail(
              selectedIndex: _index,
              onDestinationSelected: (value) {
                setState(() => _index = value);
                _loadSection(value);
              },
              labelType: NavigationRailLabelType.all,
              destinations: List.generate(
                _icons.length,
                (i) => NavigationRailDestination(
                  icon: Icon(_icons[i]),
                  label: Text(s.t(_labels[i])),
                ),
              ),
            ),
          Expanded(
            child: BlocBuilder<AdminCubit, AdminState>(
              builder: (context, state) {
                if (state.status == AdminStatus.loading ||
                    state.status == AdminStatus.initial) {
                  return const LoadingView();
                }
                if (state.status == AdminStatus.failure) {
                  return ErrorView(
                    message: state.message ?? s.t('errorGeneric'),
                    onRetry: () => _loadSection(_index),
                  );
                }
                return switch (_index) {
                  0 => _DashboardView(stats: state.stats, orders: state.orders),
                  1 => _ProductsView(products: state.products),
                  2 => _CategoriesView(categories: state.categories),
                  3 => _AdminOrdersView(orders: state.orders),
                  4 => _CustomersView(customers: state.customers),
                  _ => _InventoryView(products: state.products),
                };
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: wide
          ? null
          : NavigationBar(
              selectedIndex: _index,
              onDestinationSelected: (value) {
                setState(() => _index = value);
                _loadSection(value);
              },
              destinations: List.generate(
                _icons.length,
                (i) => NavigationDestination(
                  icon: Icon(_icons[i]),
                  label: s.t(_labels[i]),
                ),
              ),
            ),
    );
  }
}

class _DashboardView extends StatelessWidget {
  const _DashboardView({required this.stats, required this.orders});

  final Map<String, num> stats;
  final List<OrderEntity> orders;

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final cards = [
      (
        s.t('revenue'),
        s.money(stats['revenue'] ?? 0),
        Icons.attach_money_rounded,
      ),
      (
        s.t('totalOrders'),
        '${stats['orders'] ?? 0}',
        Icons.receipt_long_outlined,
      ),
      (
        s.t('totalCustomers'),
        '${stats['customers'] ?? 0}',
        Icons.people_outline_rounded,
      ),
      (
        s.t('lowStock'),
        '${stats['lowStock'] ?? 0}',
        Icons.warning_amber_rounded,
      ),
    ];
    return SingleChildScrollView(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            s.t('dashboard'),
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: cards
                .map(
                  (card) => SizedBox(
                    width: 210,
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(card.$3, color: AppColors.sage),
                            const SizedBox(height: 12),
                            Text(
                              card.$1,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              card.$2,
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 28),
          Text(s.t('orders'), style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          Card(
            child: orders.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(28),
                    child: Text(s.t('noOrders')),
                  )
                : Column(
                    children: orders.take(6).map((order) {
                      return ListTile(
                        title: Text(
                          '#${order.id.substring(0, order.id.length.clamp(0, 8))}',
                        ),
                        subtitle: Text(s.t(order.status.labelKey)),
                        trailing: Text(s.money(order.total)),
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }
}

class _ProductsView extends StatelessWidget {
  const _ProductsView({required this.products});

  final List<ProductEntity> products;

  Future<void> _editor(BuildContext context, {ProductEntity? product}) async {
    final s = AppStrings.of(context);
    final nameAr = TextEditingController(text: product?.nameAr ?? '');
    final nameEn = TextEditingController(text: product?.nameEn ?? '');
    final price = TextEditingController(text: '${product?.price ?? 0}');
    final sale = TextEditingController(text: '${product?.salePrice ?? 0}');
    final stock = TextEditingController(text: '${product?.stock ?? 0}');
    final image = TextEditingController(
      text: product?.imageUrls.isEmpty ?? true ? '' : product!.imageUrls.first,
    );
    bool active = product?.isActive ?? true;
    bool featured = product?.isFeatured ?? false;

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(product == null ? s.t('addProduct') : s.t('editProduct')),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 420,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppTextField(
                    label: '${s.t('name')} (AR)',
                    controller: nameAr,
                  ),
                  const SizedBox(height: 10),
                  AppTextField(
                    label: '${s.t('name')} (EN)',
                    controller: nameEn,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          label: s.t('price'),
                          controller: price,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: AppTextField(
                          label: s.t('discount'),
                          controller: sale,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  AppTextField(
                    label: s.t('stock'),
                    controller: stock,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 10),
                  AppTextField(label: 'Image URL', controller: image),
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    value: active,
                    onChanged: (v) => setDialogState(() => active = v ?? true),
                    title: Text(s.t('active')),
                  ),
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    value: featured,
                    onChanged: (v) =>
                        setDialogState(() => featured = v ?? false),
                    title: Text(s.t('bestSellers')),
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
              onPressed: () => Navigator.pop(context, true),
              child: Text(s.t('save')),
            ),
          ],
        ),
      ),
    );

    if (saved == true && nameAr.text.isNotEmpty && nameEn.text.isNotEmpty) {
      final images = image.text.trim().isEmpty
          ? <String>[]
          : <String>[image.text.trim()];
      await di.sl<AdminCubit>().saveProduct(
        ProductEntity(
          id: product?.id ?? '',
          categoryId: product?.categoryId ?? '',
          nameAr: nameAr.text.trim(),
          nameEn: nameEn.text.trim(),
          price: double.tryParse(price.text) ?? 0,
          salePrice: double.tryParse(sale.text) ?? 0,
          stock: int.tryParse(stock.text) ?? 0,
          isActive: active,
          isFeatured: featured,
          imageUrls: images,
        ),
      );
    }
    for (final controller in [nameAr, nameEn, price, sale, stock, image]) {
      controller.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _editor(context),
        child: const Icon(Icons.add_rounded),
      ),
      body: products.isEmpty
          ? EmptyView(
              title: s.t('noProducts'),
              subtitle: s.t('addProduct'),
              icon: Icons.local_florist_outlined,
            )
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: products.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final product = products[index];
                return Card(
                  child: ListTile(
                    leading: AppImage(
                      url: product.coverImage ?? '',
                      width: 56,
                      height: 56,
                      borderRadius: 10,
                    ),
                    title: Text(product.name(s.isArabic)),
                    subtitle: Text(
                      '${s.money(product.effectivePrice)} · ${s.t('stock')}: ${product.stock}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () => _editor(context, product: product),
                          icon: const Icon(Icons.edit_outlined, size: 18),
                          tooltip: s.t('edit'),
                        ),
                        IconButton(
                          onPressed: () =>
                              di.sl<AdminCubit>().deleteProduct(product.id),
                          icon: const Icon(
                            Icons.delete_outline_rounded,
                            size: 18,
                            color: AppColors.danger,
                          ),
                          tooltip: s.t('delete'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class _CategoriesView extends StatelessWidget {
  const _CategoriesView({required this.categories});

  final List<CategoryEntity> categories;

  Future<void> _editor(BuildContext context, {CategoryEntity? category}) async {
    final s = AppStrings.of(context);
    final ar = TextEditingController(text: category?.nameAr ?? '');
    final en = TextEditingController(text: category?.nameEn ?? '');
    final image = TextEditingController(text: category?.imageUrl ?? '');
    final sort = TextEditingController(text: '${category?.sortOrder ?? 0}');
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(category == null ? s.t('create') : s.t('edit')),
        content: SizedBox(
          width: 360,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppTextField(label: '${s.t('name')} (AR)', controller: ar),
              const SizedBox(height: 10),
              AppTextField(label: '${s.t('name')} (EN)', controller: en),
              const SizedBox(height: 10),
              AppTextField(label: 'Image URL', controller: image),
              const SizedBox(height: 10),
              AppTextField(
                label: s.t('sort'),
                controller: sort,
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(s.t('cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(s.t('save')),
          ),
        ],
      ),
    );
    if (saved == true && ar.text.isNotEmpty && en.text.isNotEmpty) {
      await di.sl<AdminCubit>().saveCategory(
        CategoryEntity(
          id: category?.id ?? '',
          nameAr: ar.text.trim(),
          nameEn: en.text.trim(),
          imageUrl: image.text.trim(),
          sortOrder: int.tryParse(sort.text) ?? 0,
        ),
      );
    }
    ar.dispose();
    en.dispose();
    image.dispose();
    sort.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _editor(context),
        child: const Icon(Icons.add_rounded),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return Card(
            child: ListTile(
              title: Text(category.name(s.isArabic)),
              subtitle: Text(category.name(!s.isArabic)),
              trailing: IconButton(
                onPressed: () => _editor(context, category: category),
                icon: const Icon(Icons.edit_outlined, size: 18),
                tooltip: s.t('edit'),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _AdminOrdersView extends StatelessWidget {
  const _AdminOrdersView({required this.orders});

  final List<OrderEntity> orders;

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    if (orders.isEmpty) {
      return EmptyView(
        title: s.t('noOrders'),
        subtitle: s.t('noOrdersSubtitle'),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: orders.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final order = orders[index];
        return Card(
          child: ListTile(
            title: Text(
              '#${order.id.substring(0, order.id.length.clamp(0, 8))}',
            ),
            subtitle: Text(
              '${order.customerName} · ${order.items.length} ${s.t('items')}',
            ),
            trailing: DropdownButton<OrderStatus>(
              value: order.status,
              underline: const SizedBox.shrink(),
              items: OrderStatus.values
                  .map(
                    (status) => DropdownMenuItem<OrderStatus>(
                      value: status,
                      child: Text(s.t(status.labelKey)),
                    ),
                  )
                  .toList(),
              onChanged: (status) {
                if (status != null) {
                  di.sl<AdminCubit>().setOrderStatus(order.id, status);
                }
              },
            ),
          ),
        );
      },
    );
  }
}

class _CustomersView extends StatelessWidget {
  const _CustomersView({required this.customers});

  final List<AppUser> customers;

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    if (customers.isEmpty) {
      return EmptyView(title: s.t('customers'), subtitle: s.t('noResults'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: customers.length,
      itemBuilder: (context, index) {
        final customer = customers[index];
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.blush,
              child: Text(
                customer.displayName.substring(
                  0,
                  customer.displayName.length.clamp(0, 1),
                ),
              ),
            ),
            title: Text(customer.displayName),
            subtitle: Text(customer.email),
            trailing: customer.role == 'admin'
                ? Chip(
                    label: Text(s.t('admin')),
                    backgroundColor: AppColors.blush,
                  )
                : null,
          ),
        );
      },
    );
  }
}

class _InventoryView extends StatelessWidget {
  const _InventoryView({required this.products});

  final List<ProductEntity> products;

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    if (products.isEmpty) {
      return EmptyView(title: s.t('noInventory'), subtitle: s.t('addProduct'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        final low = product.stock <= 5;
        return Card(
          child: ListTile(
            title: Text(product.name(s.isArabic)),
            subtitle: Text(product.categoryName(s.isArabic)),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: low
                    ? AppColors.danger.withValues(alpha: 0.1)
                    : AppColors.sage.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${product.stock}',
                style: TextStyle(
                  color: low ? AppColors.danger : AppColors.sage,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
