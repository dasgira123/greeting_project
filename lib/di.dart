import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'viewmodels/home/contact_viewmodel.dart';
import 'viewmodels/home/category_viewmodel.dart';
import 'viewmodels/home/greeting_viewmodel.dart';
import 'data/interfaces/repositories/icontact_repository.dart';
import 'data/interfaces/repositories/itemplate_repository.dart';
import 'data/implementations/repositories/contact_repository_impl.dart';
import 'data/implementations/repositories/template_repository_impl.dart';

import 'data/interfaces/repositories/icategory_repository.dart';
import 'data/implementations/repositories/category_repository_impl.dart';
import 'services/ai_service.dart';

// Tạo một danh sách chứa tất cả các Provider (ViewModel) của ứng dụng
List<SingleChildWidget> get globalProviders {
  return [
    // Data layer injection
    Provider<IContactRepository>(create: (_) => ContactRepositoryImpl()),
    Provider<ITemplateRepository>(create: (_) => TemplateRepositoryImpl()),
    Provider<ICategoryRepository>(create: (_) => CategoryRepositoryImpl()),
    Provider<AIService>(create: (_) => AIService()),
    
    // ViewModels injection
    ChangeNotifierProvider<ContactViewModel>(
      create: (context) => ContactViewModel(
        contactRepository: context.read<IContactRepository>(),
      ),
    ),
    ChangeNotifierProvider<CategoryViewModel>(
      create: (context) => CategoryViewModel(
        categoryRepository: context.read<ICategoryRepository>(),
      ),
    ),
    ChangeNotifierProvider<GreetingViewModel>(
      create: (context) => GreetingViewModel(
        templateRepository: context.read<ITemplateRepository>(),
        aiService: context.read<AIService>(),
      ),
    ),
    // Sau này có thêm ViewModel mới (ví dụ ProfileViewModel), bạn chỉ cần khai báo tiếp ở đây.
  ];
}