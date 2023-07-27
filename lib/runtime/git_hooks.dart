import 'dart:io';

import '../install/create_hooks.dart';
import '../uninstall/deleteFiles.dart';
import '../utils/logging.dart';
import '../utils/type.dart';
import '../utils/utils.dart';

/// create files or call hooks functions
class GitHooks {
  static final Ansi _ansi = Ansi(true);

  /// create files from dart codes.
  /// [targetPath] is the absolute path
  static void init({String? targetPath}) async {
    try {
      await Process.run('git_hooks', ['-v']);
    } catch (error) {
      var result = await Process.run('pub', [
        'global',
        'activate',
        '--source',
        'path',
        Utils.getOwnPath() ?? '',
        // ignore: body_might_complete_normally_catch_error
      ]).catchError((onError) {
        print(onError);
      });
      print(result.stdout);
      if (result.stderr.length != 0) {
        print(_ansi.error(result.stderr));
        print(_ansi.subtle('You can check \'git_hooks\' in your pubspec.yaml,and use \'pub get\' or \'flutter pub get\' again'));
        exit(1);
      }
      await CreateHooks.copyFile(targetPath: targetPath);
    }
  }

  /// unInstall git_hooks
  static Future<bool> unInstall({String? path}) {
    return deleteFiles();
  }

  /// get target file path.
  /// returns the path that the git hooks points to.
  static Future<String?> getTargetFilePath({String? path}) async {
    return CreateHooks.getTargetFilePath();
  }

  /// ```dart
  /// Map<Git, UserBackFun> params = {
  ///   Git.commitMsg: commitMsg,
  ///   Git.preCommit: preCommit
  /// };
  /// GitHooks.call(arguments, params);
  /// ```
  /// [argument] is just passthrough from main methods. It may ['pre-commit','commit-msg'] from [hookList]
  static void call(List<String> argument, Map<Git, UserBackFun> params) async {
    var type = argument[0];
    try {
      params.forEach((userType, function) async {
        if (hookList[userType.toString().split('.')[1]] == type) {
          if (!await params[userType]!()) {
            exit(1);
          }
        }
      });
    } catch (e) {
      print(e);
      print('git_hooks crashed when call ${type},check your function');
    }
  }
}
