import 'dart:io';

import '../git_hooks.dart';
import '../utils/logging.dart';

/// delete all file from `.git/hooks`
Future<bool> deleteFiles() async {
  var rootDir = Directory.current;
  var logger = Logger.standard();

  var gitDir = Directory(Utils.uri(rootDir.path + '/.git/'));
  var gitHookDir = Utils.gitHookFolder;
  if (!gitDir.existsSync()) {
    print(gitDir.path);
    throw ArgumentError('.git is not exists in your project');
  }
  var progress = logger.progress('delete files');
  for (var hook in hookList.values) {
    var path = gitHookDir + hook;
    var hookFile = File(path);
    if (hookFile.existsSync()) {
      await hookFile.delete();
    }
  }
  var hookFile = File(Utils.uri(rootDir.path + '/flutter_git_hooks.dart'));
  if (hookFile.existsSync()) {
    await hookFile.delete();
    print('flutter_git_hooks.dart deleted successfully!');
  }
  progress.finish(showTiming: true);
  print('All files deleted successfully!');
  await Process.run('pub', ['global', 'deactivate', 'git_hooks'])
      // ignore: body_might_complete_normally_catch_error
      .catchError((onError) {
    print(onError);
  });
  print('git_hooks uninstalled successful!');
  return true;
}
