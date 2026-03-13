import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'viewmodels/home/home_viewmodel.dart';

// Tạo một danh sách chứa tất cả các Provider (ViewModel) của ứng dụng
List<SingleChildWidget> get globalProviders {
  return [
    ChangeNotifierProvider(create: (_) => HomeViewModel()),
    // Sau này có thêm ViewModel mới (ví dụ ProfileViewModel), bạn chỉ cần khai báo tiếp ở đây:
    // ChangeNotifierProvider(create: (_) => ProfileViewModel()),
  ];
}