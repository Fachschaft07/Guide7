import 'dart:async';

import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:guide7/app-routes.dart';
import 'package:guide7/app.dart';
import 'package:guide7/connect/meal_plan/meal_plan_repository.dart';
import 'package:guide7/connect/repository.dart';
import 'package:guide7/localization/app_localizations.dart';
import 'package:guide7/model/meal_plan/canteen.dart';
import 'package:guide7/model/meal_plan/meal_plan_info.dart';
import 'package:guide7/storage/meal_plan/info/meal_plan_info_storage.dart';
import 'package:guide7/ui/common/line_separator.dart';
import 'package:guide7/ui/util/ui_util.dart';
import 'package:guide7/util/custom_colors.dart';

/// View for setting up the meal plan.
class MealPlanSetupView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MealPlanSetupViewState();
}

/// State of the meal plan setup view.
class _MealPlanSetupViewState extends State<MealPlanSetupView> {
  /// Future returning when the view is initialized.
  Future<void> _initFuture;

  /// Loaded canteens.
  List<Canteen> _canteens;

  /// The currently selected price category.
  int _selectedPriceCategory = MealPlanInfo.student;

  /// The currently selected canteen id.
  int _selectedCanteenId;

  @override
  void initState() {
    super.initState();

    _initFuture = _init();
  }

  /// Initialize the view.
  Future<void> _init() async {
    MealPlanInfoStorage storage = MealPlanInfoStorage();
    if (!(await storage.isEmpty())) {
      MealPlanInfo info = await storage.read();

      _selectedCanteenId = info.canteenId;
      _selectedPriceCategory = info.priceCategory;
    }

    _canteens = await _loadCanteens();
  }

  /// Load all canteens.
  Future<List<Canteen>> _loadCanteens() async {
    Repository repository = Repository();
    MealPlanRepository mealPlanRepository = repository.getMealPlanRepository();

    return await mealPlanRepository.loadCanteens();
  }

  @override
  Widget build(BuildContext context) => UIUtil.getScaffold(
        body: SafeArea(
          child: CustomScrollView(
            slivers: <Widget>[
              _buildAppBar(),
              _buildContent(),
            ],
          ),
        ),
      );

  /// Build the views app bar.
  Widget _buildAppBar() => UIUtil.getSliverAppBar(
      title: AppLocalizations.of(context).mealPlanSetupTitle,
      leading: BackButton(
        color: CustomColors.slateGrey,
      ));

  /// Build the dialog content.
  Widget _buildContent() {
    return SliverToBoxAdapter(
      child: FutureBuilder<void>(
        future: _initFuture,
        builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
          if (_canteens != null && _canteens.isNotEmpty && snapshot.connectionState == ConnectionState.done) {
            return _buildSetupDialog();
          } else if (snapshot.hasError && snapshot.connectionState == ConnectionState.done) {
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 40.0, horizontal: 30.0),
              child: Text(
                AppLocalizations.of(context).genericLoadError,
                style: TextStyle(fontFamily: "NotoSerifTC"),
              ),
            );
          } else {
            return Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 40.0, horizontal: 30.0),
                child: CircularProgressIndicator(),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildSeparator([String text]) {
    return Padding(
      padding: EdgeInsets.only(top: 15.0, bottom: 10.0),
      child: LineSeparator(
        title: text != null ? text : "",
        padding: 50.0,
      ),
    );
  }

  /// Build the setup dialog.
  Widget _buildSetupDialog() {
    return Column(
      children: <Widget>[
        _buildSeparator(AppLocalizations.of(context).canteen),
        _buildCanteenDropDown(),
        _buildSeparator(AppLocalizations.of(context).priceCategoryLabel),
        _buildPriceCategoryDropDown(),
        _buildSeparator(),
        RaisedButton(
          child: Text(AppLocalizations.of(context).save),
          onPressed: () {
            _submit();
          },
          color: CustomColors.slateGrey,
          textColor: Colors.white,
        ),
      ],
    );
  }

  /// Build the widget for choosing the price category.
  Widget _buildPriceCategoryDropDown() {
    AppLocalizations localizations = AppLocalizations.of(context);

    List<_PriceCategoryOption> options = [
      _PriceCategoryOption(priceCategory: MealPlanInfo.student, name: localizations.priceCategoryStudents),
      _PriceCategoryOption(priceCategory: MealPlanInfo.employee, name: localizations.priceCategoryEmployees),
      _PriceCategoryOption(priceCategory: MealPlanInfo.other, name: localizations.priceCategoryOthers),
    ];

    return DropdownButton<int>(
      items: options.map((_PriceCategoryOption option) {
        return DropdownMenuItem<int>(
          value: option.priceCategory,
          child: Text(option.name),
        );
      }).toList(),
      onChanged: (selectedPriceCategory) {
        setState(() {
          _selectedPriceCategory = selectedPriceCategory;
        });
      },
      value: _selectedPriceCategory,
    );
  }

  /// Build the dropdown list showing all available canteens.
  Widget _buildCanteenDropDown() {
    if (_selectedCanteenId == null) {
      _selectedCanteenId = _canteens.first.id;
    }

    return DropdownButton<int>(
      items: _canteens.map((Canteen canteen) {
        return DropdownMenuItem<int>(
          value: canteen.id,
          child: Text(canteen.name),
        );
      }).toList(),
      onChanged: (selectedCanteenId) {
        setState(() {
          _selectedCanteenId = selectedCanteenId;
        });
      },
      value: _selectedCanteenId,
    );
  }

  /// Submit the settings.
  void _submit() async {
    MealPlanInfo info = MealPlanInfo(
      canteenId: _selectedCanteenId,
      priceCategory: _selectedPriceCategory,
    );

    MealPlanInfoStorage storage = MealPlanInfoStorage();
    await storage.write(info);

    App.router.navigateTo(context, AppRoutes.mealPlan, transition: TransitionType.native, replace: true);
  }
}

/// Option of a dropdown button.
/// Choose the appropriate price category.
class _PriceCategoryOption {
  /// Name of the price category.
  final String name;

  /// Price category.
  final int priceCategory;

  /// Create option.
  _PriceCategoryOption({
    @required this.name,
    @required this.priceCategory,
  });
}
