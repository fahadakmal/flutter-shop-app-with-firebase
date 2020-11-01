import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shopify/models/exception.dart';
import './product.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Products with ChangeNotifier {
  List<Product> _items = [
    // Product(
    //   id: 'p1',
    //   title: 'Red Shirt',
    //   description: 'A red shirt - it is pretty red!',
    //   price: 29.99,
    //   imageUrl:
    //       'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    // ),
    // Product(
    //   id: 'p2',
    //   title: 'Blue Shirt',
    //   description: 'A red shirt - it is pretty red!',
    //   price: 29.99,
    //   imageUrl:
    //       'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    // ),
    // Product(
    //   id: 'p3',
    //   title: 'Green Shirt',
    //   description: 'A red shirt - it is pretty red!',
    //   price: 29.99,
    //   imageUrl:
    //       'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    // ),
    // Product(
    //   id: 'p4',
    //   title: 'Yellow Shirt',
    //   description: 'A red shirt - it is pretty red!',
    //   price: 29.99,
    //   imageUrl:
    //       'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    // ),
  ];

  final String authToken;
  final String userId;

  Products(this.authToken,this.userId,this._items);

  List<Product> get favoriteItems {
    return _items.where((prodItem) => prodItem.isFavorite).toList();
  }

  List<Product> get items {
    return [..._items];
  }

  Product findById(String id) {
    return _items.firstWhere(((prod) => prod.id == id));
  }

  Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
   final filterString =filterByUser == true ? 'orderBy="creatorId"&equalTo="${userId}"' : '';
    final url = 'https://flutterapp-4bc5c.firebaseio.com/products.json?auth=${authToken}&${filterString}';
    try {
      final response = await http.get(url);

      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if(extractedData == null)
      {
        return;
      }
      var favUrl = 'https://flutterapp-4bc5c.firebaseio.com/userFavorites/${userId}.json?auth=${authToken}';
      final favoriteResponse=await http.get(favUrl);
      final favoriteData=json.decode(favoriteResponse.body);

       List<Product> loadedProducts = [];

      extractedData.forEach((prodId, prodData) {
        loadedProducts.add(Product(
            id: prodId.toString(),
            title: prodData['title'],
            description: prodData['description'],
            price: prodData['price'],
            imageUrl: prodData['imageUrl'],
            isFavorite: favoriteData == null ? false : favoriteData[prodId]  ?? false));
      });

      _items = loadedProducts;
      notifyListeners();
    } catch (error) {
      print(error);
      throw (error);
    }
  }

  Future<void> addProduct(Product product) async {
    final url = 'https://flutterapp-4bc5c.firebaseio.com/products.json?auth=${authToken}';
    try {
      final response = await http.post(
        url,
        body: json.encode({
          'title': product.title,
          'description': product.description,
          'imageUrl': product.imageUrl,
          'price': product.price,
          'creatorId':userId
        }),
      );
      final newProduct = Product(
          title: product.title,
          description: product.description,
          imageUrl: product.imageUrl,
          price: product.price,
          id: json.decode(response.body)['name']);
      _items.add(newProduct);
      // _items.insert(0, newProduct); //at the beginning of the list
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final productIndex = _items.indexWhere((prod) => prod.id == id);
    if (productIndex >= 0) {
      final url = 'https://flutterapp-4bc5c.firebaseio.com/products/${id}.json?auth=${authToken}';
      try {
        await http.patch(url,
            body: json.encode({
              'title': newProduct.title,
              'description': newProduct.description,
              'imageUrl': newProduct.imageUrl,
              'peice': newProduct.price
            }));
        _items[productIndex] = newProduct;
        notifyListeners();
      } catch (error) {
        print(error);
        throw error;
      }
    }
  }

  Future<void> deleteProduct(String id) async {
    final url = 'https://flutterapp-4bc5c.firebaseio.com/products/${id}.json?auth=${authToken}';
    final exisitingProductIndex = _items.indexWhere((prod) => prod.id == id);
    final response= await http.delete(url);
    _items.removeAt(exisitingProductIndex);
    var existingProduct = _items[exisitingProductIndex];


    notifyListeners();
      if(response.statusCode >=400)
        {
          throw HttpException('Could not delete product');
          _items.insert(exisitingProductIndex, existingProduct);

          notifyListeners();
        }
      existingProduct = null;
    _items.removeAt(exisitingProductIndex);
    notifyListeners();
  }
}
