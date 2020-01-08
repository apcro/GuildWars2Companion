import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:guildwars2_companion/blocs/world_bosses/bloc.dart';
import 'package:guildwars2_companion/models/other/world_boss.dart';
import 'package:guildwars2_companion/pages/home/world_boss.dart';
import 'package:guildwars2_companion/utils/guild_wars.dart';
import 'package:guildwars2_companion/widgets/appbar.dart';
import 'package:guildwars2_companion/widgets/full_button.dart';
import 'package:intl/intl.dart';

class WorldBossesPage extends StatefulWidget {
  @override
  _WorldBossesPageState createState() => _WorldBossesPageState();
}

class _WorldBossesPageState extends State<WorldBossesPage> {

  final DateFormat timeFormat = DateFormat.Hm();

  Timer _timer;
  int _refreshTimeout = 0;

  @override
  void initState() {
    super.initState();

    BlocProvider.of<WorldBossesBloc>(context).add(LoadWorldbossesEvent(true));

    _timer = Timer.periodic(
      Duration(seconds: 1),
      (Timer timer) {
        if (_refreshTimeout > 0) {
          _refreshTimeout--;
        }

        setState(() {});
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(accentColor: Colors.deepPurple),
      child: Scaffold(
        appBar: CompanionAppBar(
          title: 'World Bosses',
          color: Colors.deepPurple,
          foregroundColor: Colors.white,
          elevation: 4.0,
        ),
        body: BlocBuilder<WorldBossesBloc, WorldBossesState>(
          builder: (context, state) {
            if (state is LoadedWorldbossesState) {
              DateTime now = DateTime.now();

              if (state.worldBosses.any((w) => w.refreshTime.toLocal().isBefore(now))
                && _refreshTimeout == 0) {
                _refreshTimeout = 30;
                BlocProvider.of<WorldBossesBloc>(context).add(LoadWorldbossesEvent(false));
              }

              return ListView(
                children: state.worldBosses
                  .map((w) => _buildWorldbossRow(context, w))
                  .toList(),
              );
            }

            return Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
      ),
    );
  }
              
  Widget _buildWorldbossRow(BuildContext context, WorldBoss worldBoss) {
    bool isActive = worldBoss.dateTime.toLocal().isBefore(DateTime.now());

    return CompanionFullButton(
      color: worldBoss.color,
      title: worldBoss.name,
      leading: Stack(
        children: <Widget>[
          Image.asset('assets/world_bosses/${worldBoss.id}.jpg'),
          if (worldBoss.completed)
            Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.white60,
              alignment: Alignment.center,
              child: Icon(
                FontAwesomeIcons.check,
                color: Colors.black87,
                size: 38.0,
              ),
            ),
        ],
      ),
      subtitles: [
        worldBoss.location,
      ],
      trailing: Padding(
        padding: EdgeInsets.only(left: 8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            if (isActive)
              Text(
                'Active',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w500,
                  color: Colors.white
                ),
              )
            else
              Text(
                GuildWarsUtil.durationToString(worldBoss.dateTime.toLocal().difference(DateTime.now())),
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w500,
                  color: Colors.white
                ),
              ),
            Text(
              timeFormat.format(worldBoss.dateTime.toLocal()),
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.0,
              ),
            )
          ],
        ),
      ),
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => WorldBossPage(worldBoss)
      )),
    );
  }
}