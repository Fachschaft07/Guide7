import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:guide7/localization/app_localizations.dart';
import 'package:guide7/model/weekplan/custom/custom_event.dart';
import 'package:guide7/model/weekplan/custom/custom_event_cycle.dart';
import 'package:guide7/ui/common/line_separator.dart';
import 'package:guide7/util/custom_colors.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

/// Dialog to create and edit custom events.
class CustomEventDialog extends StatefulWidget {
  /// Event to edit or null if creating a new one.
  final CustomEvent toEdit;

  /// What to do on submitting the event.
  final ValueChanged<CustomEvent> onSubmit;

  /// Create new custom event dialog.
  CustomEventDialog({
    @required this.onSubmit,
    this.toEdit,
  });

  @override
  State<StatefulWidget> createState() => _CustomEventDialogState();
}

/// State of the custom event dialog.
class _CustomEventDialogState extends State<CustomEventDialog> {
  /// Key of this form used to validate the form later.
  final _formKey = GlobalKey<FormState>();

  /// Date of the event.
  DateTime _selectedDate = DateTime.now();

  /// Currently selected start time.
  TimeOfDay _selectedStartTime = TimeOfDay.now();

  /// Currently selected end time.
  TimeOfDay _selectedEndTime = TimeOfDay.now().replacing(hour: TimeOfDay.now().hour + 1);

  /// Controller for the title text field.
  final TextEditingController _titleController = TextEditingController();

  /// Controller for the description text field.
  final TextEditingController _descriptionController = TextEditingController();

  /// Controller for the location text field.
  final TextEditingController _locationController = TextEditingController();

  /// Controller for the custom recurring day cycle value.
  final TextEditingController _customRecurringDayCycleController = TextEditingController();

  /// Controller for the custom recurring month cycle value.
  final TextEditingController _customRecurringMonthCycleController = TextEditingController();

  /// Controller for the custom recurring year cycle value.
  final TextEditingController _customRecurringYearCycleController = TextEditingController();

  /// How the event is recurring.
  CustomEventCycle _recurringCycle = CustomEventCycle(days: 0, months: 0, years: 0);

  @override
  void initState() {
    super.initState();

    if (widget.toEdit != null) {
      // Update fields.
      _titleController.text = widget.toEdit.title;
      _descriptionController.text = widget.toEdit.description;
      _locationController.text = widget.toEdit.location;

      _selectedDate = DateTime(widget.toEdit.start.year, widget.toEdit.start.month, widget.toEdit.start.day);
      _selectedStartTime = TimeOfDay(hour: widget.toEdit.start.hour, minute: widget.toEdit.start.minute);
      _selectedEndTime = TimeOfDay(hour: widget.toEdit.end.hour, minute: widget.toEdit.end.minute);

      _customRecurringDayCycleController.text = widget.toEdit.cycle.days.toString();
      _customRecurringMonthCycleController.text = widget.toEdit.cycle.months.toString();
      _customRecurringYearCycleController.text = widget.toEdit.cycle.years.toString();

      List<_RecurringCycleItem> items = _getRecurringCycleOptions(false);
      if (items.where((item) => item.cycle == widget.toEdit.cycle).isNotEmpty) {
        _recurringCycle = widget.toEdit.cycle;
      } else {
        _recurringCycle = CustomEventCycle(days: -1, months: -1, years: -1); // Custom cycle.
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
      child: Form(
        key: _formKey,
        child: Column(children: _buildFormContents()),
      ),
    );
  }

  /// Build the form fields.
  List<Widget> _buildFormContents() {
    DateFormat dateFormat = DateFormat.yMd(Localizations.localeOf(context).languageCode);
    DateFormat timeFormat = DateFormat.jm(Localizations.localeOf(context).languageCode);

    AppLocalizations localizations = AppLocalizations.of(context);

    List<Widget> fields = List<Widget>();

    /// Start and end time selection.
    fields.add(Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        _buildDateTimeView(
          localizations.day,
          dateFormat.format(_selectedDate),
          () async {
            DateTime now = DateTime.now();

            DateTime result = await showDatePicker(
              context: context,
              initialDate: _selectedDate,
              firstDate: _selectedDate.subtract(Duration(hours: 1)),
              lastDate: DateTime(now.year + 10),
            );

            if (result != null) {
              setState(() {
                _selectedDate = result;
              });
            }
          },
        ),
        _buildDateTimeView(
          localizations.from,
          timeFormat.format(DateTime(1, 1, 1, _selectedStartTime.hour, _selectedStartTime.minute)),
          () async {
            TimeOfDay result = await showTimePicker(
              context: context,
              initialTime: _selectedStartTime,
            );

            if (result != null) {
              setState(() {
                _selectedStartTime = result;
              });
            }
          },
        ),
        _buildDateTimeView(
          localizations.to,
          timeFormat.format(DateTime(1, 1, 1, _selectedEndTime.hour, _selectedEndTime.minute)),
          () async {
            TimeOfDay result = await showTimePicker(
              context: context,
              initialTime: _selectedEndTime,
            );

            if (result != null) {
              setState(() {
                _selectedEndTime = result;
              });
            }
          },
        ),
      ],
    ));

    fields.add(Padding(
      padding: EdgeInsets.only(top: 20.0, bottom: 10.0),
      child: LineSeparator(
        title: localizations.details,
      ),
    ));

    /// Title text field
    fields.add(
      TextFormField(
        decoration: InputDecoration(
          hintText: localizations.title,
          icon: Icon(
            Icons.title,
            color: CustomColors.slateGrey,
          ),
        ),
        validator: (value) => value.isEmpty ? localizations.createEventTitleEmptyError : null,
        controller: _titleController,
      ),
    );

    /// Description text field
    fields.add(
      TextFormField(
        decoration: InputDecoration(
          hintText: localizations.description,
          icon: Icon(
            Icons.description,
            color: CustomColors.slateGrey,
          ),
        ),
        keyboardType: TextInputType.multiline,
        maxLines: 5,
        controller: _descriptionController,
      ),
    );

    /// Location text field
    fields.add(
      TextFormField(
        decoration: InputDecoration(
          hintText: localizations.location,
          icon: Icon(
            Icons.location_on,
            color: CustomColors.slateGrey,
          ),
        ),
        keyboardType: TextInputType.multiline,
        controller: _locationController,
      ),
    );

    fields.add(Padding(
      padding: EdgeInsets.only(top: 20.0, bottom: 10.0),
      child: LineSeparator(
        title: localizations.recurring,
      ),
    ));

    List<_RecurringCycleItem> cycles = _getRecurringCycleOptions();

    fields.add(DropdownButton<CustomEventCycle>(
      items: cycles.map((_RecurringCycleItem cycle) {
        return DropdownMenuItem<CustomEventCycle>(
          value: cycle.cycle,
          child: Text(cycle.value),
        );
      }).toList(),
      onChanged: (selectedCycle) {
        setState(() {
          _recurringCycle = selectedCycle;
        });
      },
      value: _recurringCycle,
    ));

    if (isCustomCycle) {
      fields.add(Row(
        children: <Widget>[
          Expanded(
            child: TextFormField(
              decoration: InputDecoration(hintText: localizations.countOfDays),
              validator: (value) {
                int number = int.tryParse(value);

                if (number == null || number < 0) {
                  return localizations.createEventCustomRecurringCycleInvalid;
                }

                return null;
              },
              keyboardType: TextInputType.number,
              controller: _customRecurringDayCycleController,
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: 5),
              child: TextFormField(
                decoration: InputDecoration(hintText: localizations.countOfMonths),
                validator: (value) {
                  int number = int.tryParse(value);

                  if (number == null || number < 0) {
                    return localizations.createEventCustomRecurringCycleInvalid;
                  }

                  return null;
                },
                keyboardType: TextInputType.number,
                controller: _customRecurringMonthCycleController,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: 5),
              child: TextFormField(
                decoration: InputDecoration(hintText: localizations.countOfYears),
                validator: (value) {
                  int number = int.tryParse(value);

                  if (number == null || number < 0) {
                    return localizations.createEventCustomRecurringCycleInvalid;
                  }

                  return null;
                },
                keyboardType: TextInputType.number,
                controller: _customRecurringYearCycleController,
              ),
            ),
          ),
        ],
      ));
    }

    fields.add(Padding(
      padding: EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          RaisedButton.icon(
            onPressed: () {
              _submit();
            },
            icon: Icon(Icons.keyboard_arrow_right),
            label: Text(widget.toEdit == null ? localizations.create : localizations.save),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100000.0)),
            textColor: Colors.white,
            color: CustomColors.slateGrey,
          ),
        ],
      ),
    ));

    return fields;
  }

  /// Build controls view.
  Widget _buildDateTimeView(String title, String value, Function onPressed) {
    return RaisedButton(
      elevation: 0,
      padding: EdgeInsets.symmetric(
        horizontal: 15.0,
        vertical: 10.0,
      ),
      onPressed: () {
        onPressed();
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10000.0)),
      color: Color.fromRGBO(245, 245, 245, 1.0),
      child: Column(
        children: [
          Text(
            value,
          ),
          Padding(
            padding: EdgeInsets.only(
              top: 5.0,
            ),
            child: Text(
              title,
              style: TextStyle(
                color: CustomColors.slateGrey,
              ),
              textScaleFactor: 0.8,
            ),
          ),
        ],
      ),
    );
  }

  /// Submit the event.
  void _submit() {
    if (_formKey.currentState.validate()) {
      String title = _titleController.text;
      String description = _descriptionController.text;
      String location = _locationController.text;

      DateTime start = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, _selectedStartTime.hour, _selectedStartTime.minute);
      DateTime end = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, _selectedEndTime.hour, _selectedEndTime.minute);

      CustomEvent result = CustomEvent(
        uuid: widget.toEdit != null ? widget.toEdit.uuid : Uuid().v1(),
        title: title,
        description: description,
        location: location,
        cycle: !isCustomCycle
            ? _recurringCycle
            : CustomEventCycle(
                days: int.tryParse(_customRecurringDayCycleController.text),
                months: int.tryParse(_customRecurringMonthCycleController.text),
                years: int.tryParse(_customRecurringYearCycleController.text),
              ),
        start: start,
        end: end,
      );

      widget.onSubmit(result);
    }
  }

  /// Get all recurring cycle options.
  List<_RecurringCycleItem> _getRecurringCycleOptions([bool withTranslations = true]) {
    AppLocalizations localizations = withTranslations ? AppLocalizations.of(context) : null;

    return [
      _RecurringCycleItem(value: withTranslations ? localizations.onlyOnce : "", cycle: CustomEventCycle(days: 0, months: 0, years: 0)),
      _RecurringCycleItem(value: withTranslations ? localizations.daily : "", cycle: CustomEventCycle(days: 1, months: 0, years: 0)),
      _RecurringCycleItem(value: withTranslations ? localizations.weekly : "", cycle: CustomEventCycle(days: 7, months: 0, years: 0)),
      _RecurringCycleItem(value: withTranslations ? localizations.everyTwoWeeks : "", cycle: CustomEventCycle(days: 14, months: 0, years: 0)),
      _RecurringCycleItem(value: withTranslations ? localizations.custom : "", cycle: CustomEventCycle(days: -1, months: -1, years: -1)),
    ];
  }

  /// Whether the cycle is only once.
  bool get isOnlyOnce => _recurringCycle != null && _recurringCycle.years == 0 && _recurringCycle.months == 0 && _recurringCycle.days == 0;

  /// Whether custom cycle is selected.
  bool get isCustomCycle => _recurringCycle != null && _recurringCycle.years == -1 && _recurringCycle.months == -1 && _recurringCycle.days == -1;
}

/// A cycle for recurring events.
class _RecurringCycleItem {
  /// Value of the cycle.
  final String value;

  /// Recurring every [cycle].
  final CustomEventCycle cycle;

  /// Create cycle.
  const _RecurringCycleItem({
    @required this.value,
    @required this.cycle,
  });
}
