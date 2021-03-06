import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:guildwars2_companion/blocs/achievement/bloc.dart';
import 'package:guildwars2_companion/models/achievement/achievement.dart';
import 'package:guildwars2_companion/utils/guild_wars.dart';
import 'package:guildwars2_companion/widgets/accent.dart';
import 'package:guildwars2_companion/widgets/achievement_button.dart';
import 'package:guildwars2_companion/widgets/cached_image.dart';
import 'package:guildwars2_companion/widgets/card.dart';
import 'package:guildwars2_companion/widgets/coin.dart';
import 'package:guildwars2_companion/widgets/error.dart';
import 'package:guildwars2_companion/widgets/header.dart';
import 'package:guildwars2_companion/widgets/item_box.dart';
import 'package:guildwars2_companion/widgets/list_view.dart';

class AchievementPage extends StatelessWidget {

  final Achievement achievement;
  final String categoryIcon;
  final String hero;

  AchievementPage({
    this.achievement,
    this.categoryIcon,
    this.hero,
  });

  @override
  Widget build(BuildContext context) {
    return CompanionAccent(
      lightColor: Colors.blueGrey,
      child: Scaffold(
        body: BlocBuilder<AchievementBloc, AchievementState>(
          builder: (context, state) {
            if (state is ErrorAchievementsState) {
              return _buildLayout(
                context: context,
                child: Center(
                  child: CompanionError(
                    title: 'the achievement',
                    onTryAgain: () =>
                      BlocProvider.of<AchievementBloc>(context).add(LoadAchievementsEvent(
                        includeProgress: state.includesProgress
                      )),
                  ),
                )
              );
            }

            if (state is LoadedAchievementsState && state.hasError) {
              return _buildLayout(
                context: context,
                child: Center(
                  child: CompanionError(
                    title: 'the achievement',
                    onTryAgain: () =>
                      BlocProvider.of<AchievementBloc>(context).add(LoadAchievementDetailsEvent(
                      achievementId: achievement.id,
                    )),
                  ),
                ),
              );
            }

            if (state is LoadedAchievementsState) {
              Achievement _achievement = state.achievements.firstWhere((a) => a.id == achievement.id);

              if (_achievement == null) {
                return _buildLayout(
                  context: context,
                  child: Center(
                    child: CompanionError(
                      title: 'the achievement',
                      onTryAgain: () =>
                        BlocProvider.of<AchievementBloc>(context).add(LoadAchievementsEvent(
                          includeProgress: state.includesProgress
                        )),
                    ),
                  ),
                );
              }

              if (_achievement != null && _achievement.loaded) {
                if (state.includesProgress) {
                  return _buildLayout(
                    context: context,
                    favorite: _achievement.favorite,
                    state: state,
                    child: RefreshIndicator(
                      backgroundColor: Theme.of(context).accentColor,
                      color: Theme.of(context).cardColor,
                      onRefresh: () async {
                        BlocProvider.of<AchievementBloc>(context).add(RefreshAchievementProgressEvent(
                          achievementId: achievement.id,
                        ));
                        await Future.delayed(Duration(milliseconds: 200), () {});
                      },
                      child: _buildContent(context, _achievement, state),
                    ),
                  );
                }

                return _buildLayout(
                  context: context,
                  favorite: _achievement.favorite,
                  state: state,
                  child: _buildContent(context, _achievement, state),
                );
              }
            }

            return _buildLayout(
              context: context,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLayout({ BuildContext context, bool favorite, Widget child, LoadedAchievementsState state }) {
    return Column(
      children: <Widget>[
        CompanionHeader(
          isFavorite: favorite,
          onFavoriteToggle: () {
            BlocProvider.of<AchievementBloc>(context).add(ChangeFavoriteAchievementEvent(
              addAchievementId: !favorite ? achievement.id : null,
              removeAchievementId: favorite ? achievement.id : null,
            ));
          },
          includeBack: true,
          wikiName: achievement.name,
          color: Colors.blueGrey,
          child: Column(
            children: <Widget>[
              if (achievement.icon == null && categoryIcon != null && categoryIcon.contains('assets'))
                Hero(
                  tag: hero,
                  child: Image.asset(categoryIcon, height: 42.0,)
                )
              else
                Hero(
                  tag: hero,
                  child: CompanionCachedImage(
                    height: 42.0,
                    imageUrl: achievement.icon != null ? achievement.icon : categoryIcon,
                    color: Colors.white,
                    iconSize: 28,
                    fit: BoxFit.fill,
                  ),
                ),
              if (achievement.progress != null)
                _buildProgress(context),
              if (achievement.progress != null && achievement.progress.current != null && achievement.progress.max != null)
                Builder(
                  builder: (context) {
                    double progress = achievement.progress.repeated != null
                      ? achievement.progress.points / achievement.maxPoints
                      : achievement.progress.current / achievement.progress.max;

                    return Padding(
                      padding: EdgeInsets.only(top: 4.0),
                      child: Column(
                        children: <Widget>[
                          Text(
                            '${(progress * 100).round()}%',
                            style: Theme.of(context).textTheme.bodyText1.copyWith(
                              color: Colors.white
                            ),
                          ),
                          Theme(
                            data: Theme.of(context).copyWith(accentColor: Colors.white),
                            child: Container(
                              margin: EdgeInsets.all(4.0),
                              width: 128.0,
                              height: 8.0,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4.0),
                                child: LinearProgressIndicator(
                                  value: progress,
                                  backgroundColor: Colors.white24
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    );
                  }
                ),
              Padding(
                padding: EdgeInsets.only(top: 4.0),
                child: Text(
                  achievement.name,
                  style: Theme.of(context).textTheme.headline1,
                  textAlign: TextAlign.center,
                ),
              ),
              if (achievement.categoryName != null)
                Padding(
                  padding: EdgeInsets.only(top: 4.0),
                  child: Text(
                    achievement.categoryName,
                    style: Theme.of(context).textTheme.bodyText1.copyWith(
                      color: Colors.white
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: child,
        )
      ],
    );
  }

  Widget _buildContent(BuildContext context, Achievement _achievement, LoadedAchievementsState state) {
    return CompanionListView(
      children: <Widget>[
        if (_achievement.description != null && _achievement.description.isNotEmpty)
          _buildDescription(context, 'Description', GuildWarsUtil.removeOnlyHtml(_achievement.description)),
        if (_achievement.lockedText != null && _achievement.lockedText.isNotEmpty)
          _buildDescription(context, 'Locked description', GuildWarsUtil.removeOnlyHtml(_achievement.lockedText)),
        if (_achievement.requirement != null && _achievement.requirement.isNotEmpty)
          _buildDescription(context, 'Requirement', GuildWarsUtil.removeOnlyHtml(_achievement.requirement)),
        if (_achievement.rewards != null && _achievement.rewards.isNotEmpty)
          _buildRewards(context, _achievement),
        if (_achievement.prerequisitesInfo != null && _achievement.prerequisitesInfo.isNotEmpty)
          _buildPrerequisites(context, _achievement, state),
        if (_achievement.bits != null && _achievement.bits.isNotEmpty)
          _buildBits(context, _achievement, state)
      ],
    );
  }

  Widget _buildProgress(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          '${achievement.progress.points} / ${achievement.maxPoints}',
          style: Theme.of(context).textTheme.bodyText1.copyWith(
            color: Colors.white
          ),
        ),
        Container(width: 4.0,),
        Image.asset(
          'assets/progression/ap.png',
          height: 16.0,
        )
      ],
    );
  }

  Widget _buildPrerequisites(BuildContext context, Achievement _achievement, LoadedAchievementsState state) {
    return CompanionCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
            child: Text(
              'Prerequisites',
              style: Theme.of(context).textTheme.headline2,
            ),
          ),
          Column(
            children: _achievement.prerequisitesInfo
              .map((p) => CompanionAchievementButton(
                state: state,
                achievement: p,
                hero: 'pre ${p.id} ${_achievement.prerequisitesInfo.indexOf(p)}',
              ))
              .toList(),
          ),
          Container(height: 4.0,)
        ],
      ),
    );
  }

  Widget _buildRewards(BuildContext context, Achievement _achievement) {
    return CompanionCard(
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(bottom: 8.0),
            child: Text(
              'Rewards',
              style: Theme.of(context).textTheme.headline2,
            ),
          ),
          Column(
            children: _achievement.rewards
              .map((r) {
                switch (r.type) {
                  case 'Coins':
                    return Row(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: CompanionCoin(r.count),
                        ),
                      ],
                    );
                    break;
                  case 'Item':
                    return Row(
                      children: <Widget>[
                        CompanionItemBox(
                          item: r.item,
                          hero: '${r.id} ${_achievement.rewards.indexOf(r)}',
                          quantity: r.count,
                          size: 40.0,
                        ),
                        Padding(
                          padding: EdgeInsets.all(4.0),
                          child: Text(
                            r.item.name,
                            style: Theme.of(context).textTheme.bodyText1,
                            textAlign: TextAlign.center,
                          ),
                        )
                      ],
                    );
                    break;
                  case 'Mastery':
                    return Row(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Image.asset(
                            GuildWarsUtil.masteryIcon(r.region),
                            height: 32.0,
                            width: 32.0,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(4.0),
                          child: Text(
                            _masteryToName(r.region) + ' Mastery point',
                            style: Theme.of(context).textTheme.bodyText1,
                            textAlign: TextAlign.center,
                          ),
                        )
                      ],
                    );
                  case 'Title':
                    return Row(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Image.asset(
                            'assets/progression/title.png',
                            height: 32.0,
                            width: 32.0,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(4.0),
                          child: Text(
                            r.title.name,
                            style: Theme.of(context).textTheme.bodyText1,
                            textAlign: TextAlign.center,
                          ),
                        )
                      ],
                    );
                }

                return Container();
              })
              .toList(),
          )
        ],
      ),
    );
  }

  String _masteryToName(String mastery) {
    switch (mastery) {
      case 'Maguuma':
        return 'Heart of Thorns';
      case 'Desert':
        return 'Path of Fire';
      case 'Unknown':
        return 'Icebrood Saga';
      default:
        return mastery;
    }
  }

  Widget _buildBits(BuildContext context, Achievement _achievement, LoadedAchievementsState state) {
    if (_achievement.bits.any((b) => b.type == 'Text')) {
      return CompanionCard(
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(bottom: 8.0),
              child: Text(
                'Objectives',
                style: Theme.of(context).textTheme.headline2,
              ),
            ),
            Column(
              children: _achievement.bits
                .map((i) => Row(
                  children: <Widget>[
                    if (state.includesProgress &&
                      _achievement.progress != null &&
                      ((_achievement.progress.bits != null &&
                      _achievement.progress.bits.contains(_achievement.bits.indexOf(i)))
                      || _achievement.progress.done))
                      Icon(
                        FontAwesomeIcons.check,
                        size: 20.0,
                      )
                    else
                      Container(
                        width: 20.0,
                        child: Icon(
                          FontAwesomeIcons.solidCircle,
                          size: 6.0,
                        ),
                      ),
                  Expanded(
                    child: Padding(
                        padding: EdgeInsets.all(4.0),
                        child: Text(
                          i.text,
                          style: Theme.of(context).textTheme.bodyText1,
                          textAlign: TextAlign.left,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                  ],
                ))
                .toList(),
              ),
          ],
        ),
      );
    }

    return CompanionCard(
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(bottom: 8.0),
            child: Text(
              'Collection',
              style: Theme.of(context).textTheme.headline2,
            ),
          ),
          Column(
            children: _achievement.bits
              .map((i) {
                switch (i.type) {
                  case 'Item':
                    return _buildItemBit(context, _achievement, i, state.includesProgress, _achievement.bits.indexOf(i));
                    break;
                  case 'Skin':
                    return _buildSkinMiniBit(context, _achievement, i, state.includesProgress);
                    break;
                  case 'Minipet':
                    return _buildSkinMiniBit(context, _achievement, i, state.includesProgress);
                    break;
                }

                return Container();
              })
              .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildItemBit(BuildContext context, Achievement _achievement, AchievementBits bit, bool includeProgress, int bitIndex) {
    if (bit.item == null) {
      return Row(
        children: <Widget>[
          Text(
            'Unknown item',
            style: Theme.of(context).textTheme.bodyText1,
          ),
        ],
      );
    }

    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Row(
        children: <Widget>[
          CompanionItemBox(
            item: bit.item,
            size: 40.0,
            hero: '${bit.id} $bitIndex',
            markCompleted: includeProgress &&
              _achievement.progress != null &&
              ((_achievement.progress.bits != null &&
              _achievement.progress.bits.contains(_achievement.bits.indexOf(bit))
              || _achievement.progress.done)),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(4.0),
              child: Text(
                bit.item.name,
                style: Theme.of(context).textTheme.bodyText1,
                textAlign: TextAlign.left,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSkinMiniBit(BuildContext context, Achievement _achievement, AchievementBits bit, bool includeProgress) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Row(
        children: <Widget>[
          Container(
            width: 40.0,
            height: 40.0,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6.0),
              child: Stack(
                children: <Widget>[
                  CompanionCachedImage(
                    imageUrl: bit.type == 'Skin' ? bit.skin.icon : bit.mini.icon,
                    color: Colors.black,
                    iconSize: 20,
                    fit: BoxFit.fill,
                  ),
                  if (includeProgress &&
                    _achievement.progress != null &&
                    ((_achievement.progress.bits != null &&
                    _achievement.progress.bits.contains(_achievement.bits.indexOf(bit)))
                    || _achievement.progress.done))
                    Container(
                      width: double.infinity,
                      height: double.infinity,
                      color: Colors.white60,
                      alignment: Alignment.center,
                      child: Icon(
                        FontAwesomeIcons.check,
                        size: 20.0,
                      ),
                    )
                ],
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(4.0),
              child: Text(
                bit.type == 'Skin' ? bit.skin.name : bit.mini.name,
                style: Theme.of(context).textTheme.bodyText1,
                textAlign: TextAlign.left,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildDescription(BuildContext context, String title, String text) {
    return CompanionCard(
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(bottom: 8.0),
            child: Text(
              title,
              style: Theme.of(context).textTheme.headline2,
            ),
          ),
          Text(
            text,
            style: Theme.of(context).textTheme.bodyText1,
          ),
        ],
      ),
    );
  }
}