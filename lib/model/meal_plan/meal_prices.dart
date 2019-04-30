/// Different prices for a meal for categories of people.
class MealPrices {
  /// Meal price for students.
  final double students;

  /// Meal price for employees.
  final double employees;

  /// Meal price for pupils.
  final double pupils;

  /// Meal price for other guests.
  final double others;

  /// Create meal prices.
  const MealPrices({
    this.students,
    this.employees,
    this.pupils,
    this.others,
  });

  const MealPrices.empty()
      : students = null,
        employees = null,
        pupils = null,
        others = null;

  bool get hasStudentPrice => students != null;

  bool get hasEmployeePrice => employees != null;

  bool get hasPupilsPrice => pupils != null;

  bool get hasOthersPrice => others != null;

  bool get hasPrice => hasStudentPrice || hasEmployeePrice || hasPupilsPrice || hasOthersPrice;
}
