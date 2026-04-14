import 'package:bill_mate/core/constants/app_colors.dart';
import 'package:bill_mate/core/constants/app_sizes.dart';
import 'package:bill_mate/core/widgets/bill_card.dart';
import 'package:bill_mate/data/models/bill_model.dart';
import 'package:bill_mate/presentation/home/widgets/empty_state.dart';
import 'package:bill_mate/presentation/home/widgets/home_header.dart';
import 'package:bill_mate/presentation/home/widgets/option_sheet.dart';
import 'package:bill_mate/presentation/home/widgets/section_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../add_edit_bill/add_bill_screen.dart';
import 'bloc/home_bloc.dart';
import 'bloc/home_event.dart';
import 'bloc/home_state.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => HomeBloc()..add(LoadBillsEvent()),
    child: const _HomeView(),
  );
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: Builder(
        builder: (ctx) => FloatingActionButton(
          backgroundColor: AppColors.primary,
          child: const Icon(Icons.add, color: AppColors.white),
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddBillScreen()),
            );
            if (result == true) {
              context.read<HomeBloc>().add(LoadBillsEvent());
            }
          },
        ),
      ),
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          return CustomScrollView(
            slivers: [
              // ── Header ─────────────────────
             HomeHeader(state: state,),

              // ── Body ───────────────────────
              if (state is HomeLoading)
                const SliverFillRemaining(
                  child: Center(
                      child:
                      CircularProgressIndicator(color: AppColors.primary)),
                ),
              if (state is HomeError)
                SliverFillRemaining(
                  child: Center(
                    child: Text(
                      state.message,
                      style: const TextStyle(color: AppColors.overdueText),
                    ),
                  ),
                ),
              if (state is HomeLoaded)
                if (state.grouped.isEmpty)
                  const SliverFillRemaining(child: EmptyState())
                else ...[
                  _section(context, 'OVERDUE', state.grouped.overdue,state),
                  _section(context, 'DUE SOON', state.grouped.dueSoon,state),
                  _section(context, 'UPCOMING', state.grouped.upcoming,state),
                  _section(context, 'PAID', state.grouped.paid,state),
                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
            ],
          );
        },
      ),
    );
  }

  Widget _section(BuildContext context, String title,
      List<BillModel> bills, HomeLoaded state) {
    if (bills.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());
    return SliverMainAxisGroup(slivers: [
      SliverToBoxAdapter(child: SectionHeader(title: title)),
      SliverList(delegate: SliverChildBuilderDelegate(
            (ctx, i) => BillCard(
          bill: bills[i],
          onTap: () => Navigator.pushNamed(ctx, '/bill-detail', arguments: bills[i])
              .then((_) => ctx.read<HomeBloc>().add(LoadBillsEvent())),
          onLongPress: () => _showOptions(ctx, bills[i]),
        ),
        childCount: bills.length,
      )),
    ]);
  }
  void _showOptions(BuildContext context, BillModel bill) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius:
        BorderRadius.vertical(top: Radius.circular(AppSizes.radiusLg)),
      ),
      builder: (_) => OptionsSheet(
        bill: bill,
        onMarkPaid: () {
          Navigator.pop(context);
          context.read<HomeBloc>().add(MarkBillPaidEvent(bill));
        },
        onDelete: () {
          Navigator.pop(context);
          context.read<HomeBloc>().add(DeleteBillEvent(bill));
        },
      ),
    );
  }
}

