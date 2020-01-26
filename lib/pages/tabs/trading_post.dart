import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:guildwars2_companion/blocs/trading_post/bloc.dart';
import 'package:guildwars2_companion/models/trading_post/delivery.dart';
import 'package:guildwars2_companion/models/trading_post/transaction.dart';
import 'package:guildwars2_companion/pages/trading_post/trading_post_item.dart';
import 'package:guildwars2_companion/utils/guild_wars.dart';
import 'package:guildwars2_companion/widgets/appbar.dart';
import 'package:guildwars2_companion/widgets/coin.dart';
import 'package:guildwars2_companion/widgets/error.dart';
import 'package:guildwars2_companion/widgets/button.dart';
import 'package:guildwars2_companion/widgets/item_box.dart';

class TradingPostPage extends StatefulWidget {
  @override
  _TradingPostPageState createState() => _TradingPostPageState();
}

class _TradingPostPageState extends State<TradingPostPage> with TickerProviderStateMixin {

  AnimationController _rotationController;

  bool _expanded = false;

  @override
  void initState() {
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );
    super.initState();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(accentColor: Colors.green),
      child: DefaultTabController(
        length: 4,
        child: Scaffold(
          appBar: CompanionAppBar(
            title: 'Trading Post',
            color: Colors.green,
            foregroundColor: Colors.white,
          ),
          body: Column(
            children: <Widget>[
              Material(
                color: Colors.green,
                elevation: 4.0,
                child: TabBar(
                  indicatorColor: Colors.white,
                  tabs: [
                    Tab(
                      child: Text(
                        'Buying',
                        style: TextStyle(
                          fontSize: 14.0
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Tab(
                      child: Text(
                        'Selling',
                        style: TextStyle(
                          fontSize: 14.0
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Tab(
                      child: Text(
                        'Bought',
                        style: TextStyle(
                          fontSize: 14.0
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Tab(
                      child: Text(
                        'Sold',
                        style: TextStyle(
                          fontSize: 14.0
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: BlocBuilder<TradingPostBloc, TradingPostState>(
                  builder: (context, state) {
                    if (state is ErrorTradingPostState) {
                      return Center(
                        child: CompanionError(
                          title: 'the trading post',
                          onTryAgain: () =>
                            BlocProvider.of<TradingPostBloc>(context).add(LoadTradingPostEvent()),
                        ),
                      );
                    }

                    if (state is LoadedTradingPostState) {
                      return Stack(
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(bottom: 64.0),
                            child: TabBarView(
                              children: [
                                state.buying,
                                state.selling,
                                state.bought,
                                state.sold
                              ]
                              .map((t) => _buildTransactionTab(t, state))
                              .toList(),
                            ),
                          ),
                          _buildBackground(),
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: _buildDelivery(context, state.tradingPostDelivery),
                          )
                        ],
                      );
                    }

                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackground() {
    return IgnorePointer(
      ignoring: !_expanded,
      child: GestureDetector(
        onTap: () => _toggleExpanded(),
        child: AnimatedContainer(
          duration: Duration(milliseconds: 350),
          height: double.infinity,
          width: double.infinity,
          color: _expanded ? Colors.black38 : Colors.transparent,
        ),
      ),
    );
  }

  Widget _buildDelivery(BuildContext context, TradingPostDelivery tradingPostDelivery) {
    return AnimatedContainer(
      curve: Curves.ease,
      duration: Duration(milliseconds: 350),
      width: double.infinity,
      height: _expanded ? 400.0 : 64.0,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.grey,
            blurRadius: 5.0,
          ),
        ]
      ),
      child: Column(
        children: <Widget>[
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _toggleExpanded(),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0
                ),
                child: Row(
                  children: <Widget>[
                    Icon(
                      FontAwesomeIcons.inbox
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            RichText(
                              text: TextSpan(
                                text: 'Items: ',
                                style: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black
                                ),
                                children: [
                                  TextSpan(
                                    text: GuildWarsUtil.intToString(tradingPostDelivery.items.length),
                                    style: TextStyle(
                                      fontWeight: FontWeight.w400
                                    )
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              children: <Widget>[
                                Text(
                                  'Funds: ',
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black
                                  ),
                                ),
                                CompanionCoin(tradingPostDelivery.coins)
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                    RotationTransition(
                      turns: Tween(begin: 0.0, end: -0.5).animate(_rotationController),
                      child: Icon(
                        FontAwesomeIcons.chevronUp,
                        size: 18.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_expanded)
            _buildDeliveryItems(tradingPostDelivery.items)
        ],
      ),
    );
  }

  void _toggleExpanded() {
    setState(() {
      _expanded = !_expanded;
      _rotationController.animateTo(_expanded ? 1.0 : 0.0);
    });
  }

  Widget _buildDeliveryItems(List<DeliveryItem> items) {
    if (items.isEmpty) {
      return Expanded(
        child: Center(
          child: Text(
            'No items found',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 18.0
            ),
          ),
        ),
      );
    }

    return Expanded(
      child: ListView(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 4.0,
              runSpacing: 4.0,
              children: items
                .where((i) => i.id != -1)
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

  Widget _buildTransactionTab(List<TradingPostTransaction> transactions, LoadedTradingPostState state) {
    if (transactions.where((t) => t.itemInfo != null).isEmpty) {
      return RefreshIndicator(
        backgroundColor: Colors.green,
        color: Colors.white,
        onRefresh: () async {
          BlocProvider.of<TradingPostBloc>(context).add(LoadTradingPostEvent());
          await Future.delayed(Duration(milliseconds: 200), () {});
        },
        child: ListView(
          children: <Widget>[
            Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'No items found',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 18.0
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      backgroundColor: Colors.green,
      color: Colors.white,
      onRefresh: () async {
        BlocProvider.of<TradingPostBloc>(context).add(LoadTradingPostEvent());
        await Future.delayed(Duration(milliseconds: 200), () {});
      },
      child: ListView(
        children: transactions
          .where((t) => t.itemInfo != null)
          .map((t) => CompanionButton(
            leading: Stack(
              alignment: Alignment.topRight,
              children: <Widget>[
                CachedNetworkImage(
                  height: 64.0,
                  imageUrl: t.itemInfo.icon,
                  placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) => Center(child: Icon(
                    FontAwesomeIcons.dizzy,
                    size: 28,
                    color: Colors.black,
                  )),
                  fit: BoxFit.fill,
                ),
                if (t.quantity > 1)
                  Padding(
                    padding: EdgeInsets.only(right: 2.0),
                    child: Text(
                      t.quantity.toString(),
                      style: TextStyle(
                        color: Color(0xFFe3e0b5),
                        fontSize: 18.0,
                        shadows: [
                          BoxShadow(
                            color: Colors.black,
                            blurRadius: 6.0,
                          ),
                          BoxShadow(
                            color: Colors.black,
                            blurRadius: 2.0,
                          ),
                          BoxShadow(
                            color: Colors.black,
                            blurRadius: 4.0,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            subtitleWidgets: <Widget>[
              CompanionCoin(t.price)
            ],
            height: 64.0,
            title: t.itemInfo.name,
            color: Colors.white,
            foregroundColor: Colors.black,
            onTap: () {
              if (!t.loading && t.listing == null) {
                BlocProvider.of<TradingPostBloc>(context).add(LoadTradingPostListingsEvent(
                  buying: state.buying,
                  selling: state.selling,
                  bought: state.bought,
                  sold: state.sold,
                  tradingPostDelivery: state.tradingPostDelivery,
                  itemId: t.itemId
                ));
              }

              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => TradingPostItemPage(
                  item: t.itemInfo,
                  orderValue: t.purchased == null ? t.price : null,
                ),
              ));
            },
          ))
          .toList(),
      ),
    );
  }
}
