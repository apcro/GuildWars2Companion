import 'package:flutter/material.dart';

class CompanionFullButton extends StatelessWidget {
  final bool loading;
  final Widget leading;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color color;

  CompanionFullButton({
    @required this.title,
    @required this.onTap,
    @required this.color,
    this.subtitle,
    this.leading,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 80.0,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8.0,
          ),
        ],
      ),
      margin: EdgeInsets.all(8.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.0),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            splashColor: Colors.white12,
            highlightColor: Colors.white12,
            onTap: () => onTap(),
            child: Row(
              children: <Widget>[
                _buildLeading(context),
                _buildTitle(),
                _buildArrow()
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLeading(BuildContext context) {
    return Container(
      width: 80.0,
      height: 80.0,
      color: Colors.black12,
      margin: EdgeInsets.only(right: 16.0),
      alignment: Alignment.center,
      child: this.loading ?
        Theme(
          data: Theme.of(context).copyWith(accentColor: Colors.white),
          child: CircularProgressIndicator(),
        ) :
        this.leading,
    );
  }

  Widget _buildTitle() {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            this.title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.0,
              fontWeight: FontWeight.w500
            ),
          ),
          if (this.subtitle != null)
            Text(
              this.subtitle,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.0,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildArrow() {
    return Icon(
      Icons.chevron_right,
      color: Colors.white,
      size: 32.0,
    );
  }
}