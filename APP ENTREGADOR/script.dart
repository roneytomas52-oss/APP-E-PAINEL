// scripts/folder_generator/lib/generator.dart
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:args/args.dart';

void main(List<String> args) {
  final parser = ArgParser()
    ..addOption('name', abbr: 'n', help: 'Folder/module name (e.g., "user_profile")');

  ///dart run script.dart --name ride_home [command line]
  try {
    final results = parser.parse(args);
    final folderName = results['name'];
    // final structureType = results['type'];

    if (folderName == null) {
      throw Exception('Folder name is required (use --name)');
    }

    FolderGenerator.generate(folderName);
    if (kDebugMode) {
      print('✅ Successfully generated $folderName');
    }
  } catch (e) {
    if (kDebugMode) {
      print('❌ Error: $e');
    }
    exit(1);
  }
}

class FolderGenerator {

  static void generate(String folderName) {
    final libDir = Directory('lib/features/ride_module');
    final newDir = Directory(path.join(libDir.path, folderName));

    // Create folder
    newDir.createSync(recursive: true);
    if (kDebugMode) {
      print('📁 Created folder: ${newDir.path}');
    }

    final controllerDir = Directory(path.join(newDir.path, 'controllers'));
    controllerDir.createSync(recursive: true);
    _generateControllerFiles(controllerDir, folderName);

    final domainDir = Directory(path.join(newDir.path, 'domain'));
    domainDir.createSync(recursive: true);
    _generateDomainFiles(domainDir, folderName);

    final screenDir = Directory(path.join(newDir.path, 'screens'));
    screenDir.createSync(recursive: true);
    _generateScreenFiles(screenDir, folderName);

    final widgetDir = Directory(path.join(newDir.path, 'widgets'));
    widgetDir.createSync(recursive: true);

  }

  static void _generateDomainFiles(Directory dir, String name) {
    final modelDir = Directory(path.join(dir.path, 'models'));
    modelDir.createSync(recursive: true);
    _generateModelFiles(modelDir, name);

    final repoDir = Directory(path.join(dir.path, 'repositories'));
    repoDir.createSync(recursive: true);
    _generateRepoFiles(repoDir, name);

    final serviceDir = Directory(path.join(dir.path, 'services'));
    serviceDir.createSync(recursive: true);
    _generateServiceFiles(serviceDir, name);
  }

  ///generate repo demo files
  static void _generateRepoFiles(Directory dir, String name) {
    final className = _toPascalCase(name);
    final instanceName = _toLowerCase(name);
    File(path.join(dir.path, '${name}_repository.dart'))
        .writeAsStringSync(_templates['repo']!.replaceAll('{className}', className).replaceAll('{instanceName}', instanceName));

    File(path.join(dir.path, '${name}_repository_interface.dart'))
        .writeAsStringSync(_templates['repo_interface']!.replaceAll('{className}', className).replaceAll('{instanceName}', instanceName));
  }

  ///generate service demo files
  static void _generateServiceFiles(Directory dir, String name) {
    final className = _toPascalCase(name);
    final instanceName = _toLowerCase(name);
    File(path.join(dir.path, '${name}_service.dart'))
        .writeAsStringSync(_templates['service']!.replaceAll('{className}', className).replaceAll('{instanceName}', instanceName));

    File(path.join(dir.path, '${name}_service_interface.dart'))
        .writeAsStringSync(_templates['service_interface']!.replaceAll('{className}', className));
  }

  ///generate model demo file
  static void _generateModelFiles(Directory dir, String name) {
    final className = _toPascalCase(name);
    File(path.join(dir.path, '${name}_model.dart'))
        .writeAsStringSync(_templates['model']!.replaceAll('{className}', className));
  }

  ///generate screen demo file
  static void _generateScreenFiles(Directory dir, String name) {
    final className = _toPascalCase(name);
    File(path.join(dir.path, '${name}_screen.dart'))
        .writeAsStringSync(_templates['screen']!.replaceAll('{className}', className));
  }

  ///generate controller demo file
  static void _generateControllerFiles(Directory dir, String name) {
    final className = _toPascalCase(name);
    final instanceName = _toLowerCase(name);
    File(path.join(dir.path, '${name}_controller.dart'))
        .writeAsStringSync(_templates['controller']!.replaceAll('{className}', className).replaceAll('{instanceName}', instanceName));
  }

  static String _toPascalCase(String input) {
    return input.split('_').map((s) => s[0].toUpperCase() + s.substring(1)).join();
  }

  static String _toLowerCase(String input) {
    return input;
  }

  static final Map<String, String> _templates = {
    'screen': '''
  import 'package:flutter/material.dart';
  
  class {className}Screen extends StatelessWidget {
    const {className}Screen({super.key});
  
    @override
    Widget build(BuildContext context) {
      return Scaffold(
        body: Center(child: Text('{className} Screen')),
      );
    }
  }
  ''',
    'controller': '''
  import 'package:get/get.dart';
  import '../domain/services/{instanceName}_service_interface.dart';
  
  class {className}Controller extends GetxController implements GetxService {
    final {className}ServiceInterface {instanceName}ServiceInterface;
  
    {className}Controller({required this.{instanceName}ServiceInterface});
  
    bool _isLoading = false;
    bool get isLoading => _isLoading;
  }
  ''',

    'model': '''
class {className}Model {
  int? id;
  String? name;

  {className}Model({this.id, this.name});

  {className}Model.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    return data;
  }
}
  ''',

    'repo': '''
   
import '../../../../../api/api_client.dart';
import '{instanceName}_repository_interface.dart';

class {className}Repository implements {className}RepositoryInterface {
  final ApiClient apiClient;
  {className}Repository({required this.apiClient});

  @override
  Future add(value) {
    // TODO: implement add
    throw UnimplementedError();
  }

  @override
  Future delete(int? id) {
    // TODO: implement delete
    throw UnimplementedError();
  }

  @override
  Future get(int? id) {
    // TODO: implement get
    throw UnimplementedError();
  }

  @override
  Future getList({int? offset}) {
    // TODO: implement getList
    throw UnimplementedError();
  }

  @override
  Future update(Map<String, dynamic> body) {
    // TODO: implement update
    throw UnimplementedError();
  }

}
  ''',
    'repo_interface': '''
  import '../../../../../interface/repository_interface.dart';

  abstract class {className}RepositoryInterface extends RepositoryInterface {
  }
  ''',

    'service': '''
  import '../repositories/{instanceName}_repository_interface.dart';
  import '{instanceName}_service_interface.dart';
  
  class {className}Service implements {className}ServiceInterface {
    final {className}RepositoryInterface {instanceName}RepositoryInterface;
    {className}Service({required this.{instanceName}RepositoryInterface});
  
  }
  ''',

    'service_interface': '''
  abstract class {className}ServiceInterface {
  }
  ''',
  };
}