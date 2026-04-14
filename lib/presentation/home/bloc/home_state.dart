// home_state.dart
import '../../../domain/entities/bill_groups.dart';

abstract class HomeState {}

class HomeInitial extends HomeState {}
class HomeLoading extends HomeState {}
class HomeError extends HomeState {
  final String message;
  HomeError({required this.message});
}

class HomeLoaded extends HomeState {
  final BillGroups grouped;

  HomeLoaded({required this.grouped});
}