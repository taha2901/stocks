// import 'package:websiteme/core/helper/api_paths.dart';
// import 'package:websiteme/core/helper/firestore_services.dart';
// import 'package:websiteme/models/category.dart';

// abstract class CategoryServices {
//   Future<List<CategoryModel>> fetchAllCategories();
// }

// class CategoryServicesImpl implements CategoryServices {
//   final firestore = FirestoreServices.instance;

//   @override
//   Future<List<CategoryModel>> fetchAllCategories() async {
//     return firestore.getCollection<CategoryModel>(
//       path: ApiPaths.categories(),
//       builder: (data, documentId) => CategoryModel.fromMap(data, documentId),
//     );
//   }
// }
