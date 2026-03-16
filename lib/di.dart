import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'viewmodels/home/home_viewmodel.dart';
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
    ChangeNotifierProxyProvider4<IContactRepository, ICategoryRepository, ITemplateRepository, AIService, HomeViewModel>(
      create: (context) => HomeViewModel(
        contactRepository: context.read<IContactRepository>(),
        categoryRepository: context.read<ICategoryRepository>(),
        templateRepository: context.read<ITemplateRepository>(),
        aiService: context.read<AIService>(),
      ),
      update: (context, contactRepo, categoryRepo, templateRepo, aiService, previous) => 
          previous ?? HomeViewModel(
                        contactRepository: contactRepo, 
                        categoryRepository: categoryRepo,
                        templateRepository: templateRepo,
                        aiService: aiService
                      ),
    ),
    // Sau này có thêm ViewModel mới (ví dụ ProfileViewModel), bạn chỉ cần khai báo tiếp ở đây.
  ];
}