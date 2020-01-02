import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guildwars2_companion/blocs/bank/bloc.dart';
import 'package:guildwars2_companion/models/bank/material_category.dart';
import 'package:guildwars2_companion/widgets/appbar.dart';
import 'package:guildwars2_companion/widgets/item_box.dart';

class MaterialPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CompanionAppBar(
        title: 'Materials',
        color: Colors.deepOrange,
        foregroundColor: Colors.white,
        elevation: 4.0,
      ),
      body: BlocBuilder<BankBloc, BankState>(
        builder: (context, state) {
          if (state is LoadedBankState) {
            return Theme(
              data: Theme.of(context).copyWith(accentColor: Colors.deepOrange),
              child: ListView(
                children: state.materialCategories
                  .map((c) => _buildMaterialCategory(c))
                  .toList(),
              )
            );
          }

          return Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }

  Widget _buildMaterialCategory(MaterialCategory category) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              category.name,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 18.0
              ),
            ),
          ),
          Container(
            width: double.infinity,
            margin: EdgeInsets.only(top: 8.0),
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 4.0,
              runSpacing: 4.0,
              children: category.materials
                .map((i) => CompanionItemBox(
                  item: i.itemInfo,
                  quantity: i.count,
                  includeMargin: false,
                ))
                .toList(),
            ),
          ),
        ],
      ),
    );
  }
}