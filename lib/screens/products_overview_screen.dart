import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart';
import '../widgets/products_grid.dart';
import 'package:provider/provider.dart';
import '../widgets/badge.dart';
import '../providers/cart.dart';
import '../screens/cart_screen.dart';
import '../providers/products..dart';

enum FilterOptions {
  Favorites,
  All,
}

class ProductOverViewScreen extends StatefulWidget {
  @override
  _ProductOverViewScreenState createState() => _ProductOverViewScreenState();
}

class _ProductOverViewScreenState extends State<ProductOverViewScreen> {
  var _showOnlyFavorites = false;
  var _isInit=true;
  var _isLoading=false;

  @override
  void initState() {
    // Future.delayed(Duration.zero).then((value) =>
    //
    // );
    super.initState();
  }

  @override
  void didChangeDependencies() {
  if(_isInit)
    {
      setState(() {
        _isLoading=true;
      });

      Provider.of<Products>(context).fetchAndSetProducts().then((value) =>
          setState(() {
            _isLoading=false;
          })

      );
    }
  _isInit=false;
    super.didChangeDependencies();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Menu'),
        actions: <Widget>[
          PopupMenuButton(
            onSelected: (FilterOptions selectedValue) {
              setState(() {
                if (selectedValue == FilterOptions.Favorites) {
                  _showOnlyFavorites = true;
                } else {
                  _showOnlyFavorites = false;
                }
              });
            },
            icon: Icon(
              Icons.more_vert,
            ),
            itemBuilder: (_) => [
              PopupMenuItem(
                  child: Text('Only Favorites'),
                  value: FilterOptions.Favorites),
              PopupMenuItem(child: Text('Show All'), value: FilterOptions.All),
            ],
          ),
          Consumer<Cart>(
            builder: (ctx, cart, ch) =>
                Badge(child: ch, value: cart.itemCount.toString()),
            child: IconButton(
              icon: Icon(Icons.shopping_cart),
              onPressed: () {
              Navigator.of(context).pushNamed(CartScreen.routeName);
              },
            ),
          ),
        ],
      ),
      drawer: AppDrawer(),
      body:_isLoading ? Center(child: CircularProgressIndicator(),) : ProductsGrid(_showOnlyFavorites),
    );
  }
}
