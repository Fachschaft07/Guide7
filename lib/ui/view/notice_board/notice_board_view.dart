import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:guide7/connect/repository.dart';
import 'package:guide7/localization/app_localizations.dart';
import 'package:guide7/model/hm_people/hm_person.dart';
import 'package:guide7/model/notice_board/notice_board_entry.dart';
import 'package:guide7/ui/util/ui_util.dart';
import 'package:guide7/ui/view/notice_board/entry/notice_board_entry_widget.dart';
import 'package:guide7/util/custom_colors.dart';

/// View showing the notice board.
class NoticeBoardView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _NoticeBoardViewState();
}

/// State of the notice board view.
class _NoticeBoardViewState extends State<NoticeBoardView> {
  /// Future which will provide notice board entries once finished.
  Future _future;

  /// Whether to show the search field.
  bool _showSearchField = false;

  /// Text controller for the search field.
  TextEditingController _searchFieldController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _getEntries();
  }

  /// Refresh the view.
  Future<dynamic> _getEntries({bool fromCache = true}) {
    Future<List<NoticeBoardEntry>> entriesFuture = _reloadEntries(fromCache: fromCache);
    Future<List<HMPerson>> hmPeopleFuture = _getHMPeople();

    Future future = Future.wait([
      entriesFuture,
      hmPeopleFuture,
    ]);

    setState(() {
      _future = future;
    });

    return future;
  }

  /// Reload notice board entries.
  Future<List<NoticeBoardEntry>> _reloadEntries({bool fromCache = true}) async {
    var repository = Repository();
    var noticeBoardRepo = repository.getNoticeBoardRepository();

    if (fromCache && await noticeBoardRepo.hasCachedEntries()) {
      return await noticeBoardRepo.getCachedEntries();
    } else {
      return await noticeBoardRepo.loadEntries();
    }
  }

  /// Get all hm people to show their avatars.
  Future<List<HMPerson>> _getHMPeople() async {
    var repo = Repository();
    var hmPeopleRepo = repo.getHMPeopleRepository();

    if (await hmPeopleRepo.hasCachedPeople()) {
      return await hmPeopleRepo.getCachedPeople();
    } else {
      return await hmPeopleRepo.loadPeople();
    }
  }

  @override
  Widget build(BuildContext context) => SafeArea(child: _buildContent());

  /// Build the notice board views content.
  Widget _buildContent() => FutureBuilder<List<dynamic>>(
        future: _future,
        builder: (context, snapshot) {
          Widget sliverList;

          if (snapshot.hasData) {
            List<NoticeBoardEntry> entries = snapshot.data[0];
            List<HMPerson> hmPeople = snapshot.data[1];

            if (_showSearchField) {
              entries = _filterEntries(entries, _searchFieldController.text);
            }

            sliverList = SliverList(delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                if (entries.length > index) {
                  return NoticeBoardEntryWidget(
                    entry: entries[index],
                    isLast: entries.length - 1 == index,
                    avatarImage: _getAuthorImage(entries[index].author, hmPeople),
                  );
                }

                return null;
              },
            ));
          } else if (snapshot.hasError) {
            sliverList = SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 40.0, horizontal: 30.0),
                child: Text(
                  AppLocalizations.of(context).noticeBoardEntryLoadError,
                  style: TextStyle(fontFamily: "NotoSerifTC"),
                ),
              ),
            );
          } else {
            sliverList = SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 40.0, horizontal: 30.0),
                  child: CircularProgressIndicator(),
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => _getEntries(fromCache: false),
            child: CustomScrollView(
              slivers: <Widget>[
                _buildAppBar(),
                sliverList,
              ],
            ),
          );
        },
      );

  /// Build the notice board app bar.
  Widget _buildAppBar() {
    if (_showSearchField) {
      return _buildSearchAppBar();
    } else {
      return _buildDefaultAppBar();
    }
  }

  /// Build the search app bar.
  Widget _buildSearchAppBar() => SliverAppBar(
        title: Container(
          child: TextField(
            controller: _searchFieldController,
            onChanged: (text) {
              setState(() {});
            },
            style: TextStyle(
              color: Colors.black87,
              fontSize: 16.0,
            ),
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context).doSearch,
              icon: Icon(
                Icons.search,
                color: CustomColors.slateGrey,
              ),
              border: InputBorder.none,
            ),
            autofocus: true,
          ),
          decoration: BoxDecoration(color: Color.fromRGBO(240, 240, 240, 1.0), borderRadius: BorderRadius.circular(100000.0)),
          padding: EdgeInsets.symmetric(horizontal: 10.0),
        ),
        centerTitle: false,
        backgroundColor: Colors.white,
        snap: true,
        floating: true,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.close, color: CustomColors.slateGrey),
            tooltip: AppLocalizations.of(context).endSearch,
            onPressed: () {
              setState(() {
                _showSearchField = false;
                _searchFieldController.clear();
              });
            },
          ),
        ],
      );

  /// Build the default app bar for the notice board.
  Widget _buildDefaultAppBar() => UIUtil.getSliverAppBar(
        title: AppLocalizations.of(context).noticeBoard,
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: CustomColors.slateGrey),
            tooltip: AppLocalizations.of(context).search,
            onPressed: () {
              setState(() {
                _showSearchField = true;
              });
            },
          ),
        ],
      );

  /// Get image of the author or null if not found.
  Uint8List _getAuthorImage(String authorName, List<HMPerson> hmPeople) {
    HMPerson authorPerson = _findAuthorByName(authorName, hmPeople);

    return authorPerson != null && authorPerson.hasImage ? authorPerson.image : null;
  }

  /// Find the authors HMPerson instance by its name.
  HMPerson _findAuthorByName(String authorName, List<HMPerson> hmPeople) {
    for (HMPerson person in hmPeople) {
      if (_isAuthorHMPerson(authorName, person)) {
        return person;
      }
    }

    return null;
  }

  /// Check if the passed author name matches the passed person.
  bool _isAuthorHMPerson(String authorName, HMPerson person) {
    String name = person.name;

    List<String> nameParts = name.split(" ");

    // Remove titles from name if any.
    nameParts = nameParts.where((part) => !part.endsWith(".")).toList(growable: false);

    if (nameParts.length < 2) {
      return false;
    }

    String firstName = nameParts.first.toLowerCase()[0]; // Only initial char.
    String lastName = nameParts.last.toLowerCase();

    // Compare first and last name.
    List<String> authorNames = authorName.trim().split(" ");

    if (authorNames.length != 2) {
      return false;
    }

    String firstName2 = authorNames[1].substring(0, authorNames[1].length - 1).toLowerCase();
    String lastName2 = authorNames[0].substring(0, authorNames[0].length - 1).toLowerCase();

    return firstName == firstName2 && lastName == lastName2;
  }

  /// Filter the passed notice board [entries] by the passed [filterString].
  List<NoticeBoardEntry> _filterEntries(List<NoticeBoardEntry> entries, String filterString) {
    filterString = filterString.toLowerCase();

    return entries
        .where((entry) =>
            entry.title.toLowerCase().contains(filterString) ||
            entry.author.toLowerCase().contains(filterString) ||
            entry.content.toLowerCase().contains(filterString))
        .toList(growable: false);
  }
}
