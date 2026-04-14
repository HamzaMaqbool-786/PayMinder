abstract class HistoryEvent {}

class LoadHistoryEvent extends HistoryEvent {}

class FilterMonthEvent extends HistoryEvent {
  final DateTime? month;
  FilterMonthEvent(this.month);
}