import 'dart:io';

import 'package:flutter_git_hooks/git_hooks.dart';

void main(List arguments) {
  // ignore: omit_local_variable_types
  Map<Git, UserBackFun> params = {Git.commitMsg: commitMsg, Git.preCommit: preCommit};
  GitHooks.call(arguments as List<String>, params);
}

Future<bool> commitMsg() async {
  var commitMsg = Utils.getCommitEditMsg();
  if (commitMsg.startsWith('fix:')) {
    return true; // you can return true let commit go
  } else {
    print('you should add `fix` in the commit message');
    return false;
  }
  return true;
}

Future<bool> preCommit() async {
  try {
    // ProcessResult result = await Process.run('dart analyzer', ['bin']);
    ProcessResult result = Process.runSync('dart', ['analyze'], runInShell: true);
    print(result.stdout);
    return !(result.exitCode != 0);
  } catch (e) {
    return false;
  }
  return true;
}
