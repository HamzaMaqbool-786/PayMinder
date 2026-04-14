abstract class BillFormState {}

class BillFormInitial extends BillFormState {}

class BillFormLoading extends BillFormState {}

class BillFormSuccess extends BillFormState {}

class BillFormError extends BillFormState {
  final String message;
  BillFormError(this.message);
}

class BillFormUpdated extends BillFormState {
  final String? photoPath;
  BillFormUpdated({this.photoPath});
}