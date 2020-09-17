import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guildwars2_companion/blocs/character/bloc.dart';
import 'package:guildwars2_companion/models/character/bags.dart';
import 'package:guildwars2_companion/models/character/character.dart';
import 'package:guildwars2_companion/models/items/inventory.dart';
import 'package:guildwars2_companion/widgets/accent.dart';
import 'package:guildwars2_companion/widgets/appbar.dart';
import 'package:guildwars2_companion/widgets/card.dart';
import 'package:guildwars2_companion/widgets/error.dart';
import 'package:guildwars2_companion/widgets/item_box.dart';
import 'package:guildwars2_companion/widgets/list_view.dart';

class BackstoryPage extends StatelessWidget {

  final Character _character;

  BackstoryPage(this._character);

  @override
  Widget build(BuildContext context) {
    return CompanionAccent(
      lightColor: Colors.indigo,
      child: Scaffold(
        appBar: CompanionAppBar(
          title: 'My Story',
          color: Colors.indigo,
          foregroundColor: Colors.white,
          elevation: 4.0,
        ),
        body: BlocConsumer<CharacterBloc, CharacterState>(
          listenWhen: (previous, current) => current is ErrorCharactersState,
          listener: (context, state) => Navigator.of(context).pop(),
          builder: (context, state) {
            if (state is ErrorCharactersState) {
              return Center(
                child: CompanionError(
                  title: 'the character',
                  onTryAgain: () =>
                      BlocProvider.of<CharacterBloc>(context).add(RefreshCharacterDetailsEvent()),
                ),
              );
            }

            if (state is LoadedCharactersState && state.detailsError) {
              return Center(
                child: CompanionError(
                  title: 'the character items',
                  onTryAgain: () =>
                      BlocProvider.of<CharacterBloc>(context).add(LoadCharacterDetailsEvent()),
                ),
              );
            }

            if (state is LoadedCharactersState && state.detailsLoaded) {
              Character character = state.characters.firstWhere((c) => c.name == _character.name);

              if (character == null) {
                return Center(
                  child: CompanionError(
                    title: 'the character',
                    onTryAgain: () =>
                        BlocProvider.of<CharacterBloc>(context).add(RefreshCharacterDetailsEvent()),
                  ),
                );
              }

              return RefreshIndicator(
                backgroundColor: Theme.of(context).accentColor,
                color: Theme.of(context).cardColor,
                onRefresh: () async {
                  BlocProvider.of<CharacterBloc>(context).add(RefreshCharacterDetailsEvent());
                  await Future.delayed(Duration(milliseconds: 200), () {});
                },
                child: CompanionListView(
                  children: character.bags.map((b) => _buildStory(context, character.backStory)).toList(),
                ),
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

  Widget _buildStory(BuildContext context, List<String> story) {
    return CompanionCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: <Widget>[
            Divider(
                height: 2,
                thickness: 1
            ),
        ],
      ),
    );
  }
}
