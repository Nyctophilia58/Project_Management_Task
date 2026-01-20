import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/buyer_service.dart';
import '../../../shared/models/project.dart';
import '../../../shared/models/task.dart';
import '../../../shared/models/simple_user.dart';

final buyerServiceProvider = Provider((ref) => BuyerService());

final myProjectsProvider = FutureProvider<List<Project>>((ref) async {
  return ref.read(buyerServiceProvider).getMyProjects();
});

final developersProvider = FutureProvider<List<SimpleUser>>((ref) async {
  return ref.read(buyerServiceProvider).getDevelopers();
});

final projectTasksProvider = FutureProvider.family<List<Task>, int>((ref, projectId) async {
  return ref.read(buyerServiceProvider).getTasksForProject(projectId);
});