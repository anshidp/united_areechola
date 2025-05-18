import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:united_areechola/Models/usermodel.dart';
import 'package:united_areechola/addUser/repository/repository.dart';

final addusercontrollerProvider =
    StateNotifierProvider<AdduserController, List<Usermodel>>(
        (ref) => AdduserController(ref: ref));

final getuserStreamprovider = StreamProvider.family<List<Usermodel>, String>(
    (ref, String seachvalue) => ref
        .read(addusercontrollerProvider.notifier)
        .getUsers(search: seachvalue));

class AdduserController extends StateNotifier<List<Usermodel>> {
  final Ref _ref;
  AdduserController({required Ref ref})
      : _ref = ref,
        super([]);

  Stream<List<Usermodel>> getUsers({required String search}) {
    final data = _ref.read(adduserRepositoryProvider);
    return data.getUsers(seach: search);
  }
}
